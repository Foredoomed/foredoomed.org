---
layout: post
title: "使用Google Oauth 2.0来登陆应用"
date: 2013-07-05 22:41
---
最近在给公司的项目做Google Oauth 2.0的认证登陆功能，在这过程中也遇到了一些问题，特别记录下备忘。

认证有好几种方式，与Web应用有关的内容都可以在[Using OAuth 2.0 for Web Server Applications](https://developers.google.com/accounts/docs/OAuth2WebServer)找到。虽然如此，当初就是没有仔细地读一遍而走了不少弯路，所以文档要仔细读啊。

开始做认证之前，需要先去[Google APIs console](https://developers.google.com/accounts/docs/OAuth2WebServer)创建一个client id，在创建的过程中需要你填入认证成功后的重定向url，对我来说就是项目首页的url。有了client id和redirect uri后就可以来做认证了，代码非常简单：

{% hl %}

String url =  BrowserClientRequestUrl("https://accounts.google.com/o/oauth2/auth", "client.id").setRedirectUri("redirect.url").setScopes(Arrays.asList("email", "profile")).setResponseTypes(Arrays.asList("code")).build();


{% endhl %}

这段代码的目的就是来构建一个认证的url，需要用到[google-oauth-client](https://code.google.com/p/google-oauth-java-client/wiki/Setup)。其中的client id和redirect url都可以在APIs console上找到，然后只要重定向到这个url就可以了。在完成Google帐号的验证后就会被重定向到之前的redirect url，也就是我项目的首页。但是这样有个问题，那就是所有有Google帐号并且知道项目的登陆地址的话，他就可以成功地登陆，这对于我们这个项目来说是不允许的，所以需要做第二次的认证。

第二次认证的流程是：拿用户在Google登陆成功用的email，然后在允许用户登陆的表中查找这个email是否存在，若存在就允许登陆，否则不允许。那怎么拿到用户在Google登陆成功的email呢？其实这只要再发个请求到**https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=xxx**就可以了，它会返回json格式的用户信息。

{% hl %}

public String getUserEmailAddress(String code) throws IOException {

    GoogleTokenResponse googleTokenResponse = new GoogleAuthorizationCodeTokenRequest(new NetHttpTransport(),
				new JacksonFactory(), "client.id", "client.secret",**code**, "redirect.url").execute();

    String token = googleTokenResponse.getAccessToken();
    HttpClient httpClient = MpUtils.createHttpClient();
    HttpGet get = new HttpGet("https://www.googleapis.com/oauth2/v1/userinfo?alt=json" + "&access_token=" + token);
    HttpResponse response = httpClient.execute(get);

    return EntityUtils.toString(response.getEntity());
}
	
{% endhl %}

上面的代码用到了google-api-client和google-http-client库。其中的code可以用**HttpServletRequest.getParameter("code")**拿到。现在只要解析这个返回的json就可以了。需要注意的是第一次构建url的时候，**response type**这个字段一定要设成**code**，这样才能在callback中拿到这个code。