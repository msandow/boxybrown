# BoxyBrown ![alt text](http://forums.kingdomofloathing.com/vb/customavatars/avatar192782_1.gif "A #1 Duke of New York")

---

BoxyBrown is a tool for creating simple, direct [ExpressJS](http://expressjs.com/) routes to a complex variety of files. It also does automatic re-buildling of source files when in a dev environment, and E-tag generation for caching performance.

## General Use

BoxyBrown provides a set of helpful methods that can all be fed to Express routers in a style such as:

```javascript
    var Boxy = require('BoxyBrown'),
    router = new Express.Router;
    
    router.use(Boxy.MethodName());
```

## API

### Methods

See the Boxy methods below for the router-specific cases covered:

Method | Usage
--- | ---
`CoffeeJs` | Allows you to target a single CoffeeScript file for serving as JS, complete with sourcemaps and minification.
`Js` | Exactly like `CoffeeJs` but without the Coffee to Js transform.
`ScssCss` | Allows you to target a single SASS/SCSS file for serving as CSS, complete with sourcemaps.
`LessCss` | Allows you to target a single LESS file for serving as CSS, complete with sourcemaps.
`Tokenized` | Allows you to target a single textual file for serving as the same content type as the original, but with CoffeeScript-style `#{token}` tokenized string replacements.
`Remote` | Allows you to serve a remote file as a local route, with the same content type as the original remote source. Basically a proxy.

### Parameters

All of the above Boxy methods accept the following parameters:

Parameter | Usage
--- | ---
`route` [String] | The local Express route that will serve the content when a `GET` request matching the route is fielded,
`source` [String] | For `Coffee / JS / SCSS / LESS` files, this is the source library file to compile and serve. For `Tokenized` files, this is the local file to read and replace tokens in. For `Remote` files, this is the remote destination URL to load.
`debug` [Boolean] | If true, local files will be watched for changes, which will automatically re-compile their served data. For applicable `Coffee / JS / SCSS / LESS` files, true will also generate source maps for their source files, that will be served on the original `route` with the `.map` extension added.
`tokens` [Object] | For `Tokenized` files, this is the key / value pairs to search and replace in the `source` file. The key being the `#{key}` to search for, and replace with the value.
`silent` [Boolean] | If true, disables logging of file compliation in the console.
`ttl` [Integer] | A max time to store the compiled file for automatically rebuliding it. Useful for `Remote` files when you want to refresh from the source periodically.

### Extra Features

The following methods also support using special Base64 tokenization commands: `CoffeeJs`, `Js`, `ScssCss`, `LessCss`, `Tokenized`. In any of those files, you can add `%BASE64('FILE_PATH')%`, which at render time will be replaced with a Base64 string representation of `FILE_PATH` file.