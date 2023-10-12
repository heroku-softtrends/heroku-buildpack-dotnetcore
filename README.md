# .NET Core Custom Buildpack for Heroku
### For .Net Core LTS 3.1 to Latest Versions
## by Softtrends LLC

This Buidpack can be used to compile and deploy .Net Core application, ASP.Net Application, ASP.Net MVC Application to Heroku. It will pull the .NET Core dependencies from Microsoft, build a .NET Core Application and deploy it to the Heroku Platform. You should use Visual Studio 2019 and higher for best compatibility. Any tool from Visual Studio Code to the fully-featured Visual Studio Enterprise is supported.

# Install Specific Version
If we find a 'productVersion.txt' file at the root of any folder, we'll use its contents to resolve the version of what's in the folder, superseding the specified version.
  - Sample 'productVersion.txt' file content
    ```
    8.0.100-rc.1.23463.5
    ```

# References

.NET Core [Learn what's new](https://docs.microsoft.com/en-us/dotnet/core/)<br/>
ASP.NET Core [Learn what's new](https://go.microsoft.com/fwlink/?LinkId=518016)<br/>
Visual Studio [Learn and download](https://www.visualstudio.com/)<br/>
Heroku Buildpacks [How to use](https://devcenter.heroku.com/articles/buildpacks#setting-a-buildpack-on-an-application)
<br/>
