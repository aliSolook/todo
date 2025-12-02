'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "8f0947e6e48cc773bd0712f43a595007",
"assets/AssetManifest.bin.json": "4f079a395fb2332329992cabdad32edc",
"assets/AssetManifest.json": "2e32d8a07ef5391700231602fb30ad59",
"assets/assets/fonts/Shabnam-Bold.ttf": "46e5d535fe67587761993f17835e382e",
"assets/assets/fonts/Shabnam-Light.ttf": "9c0f2c8d9b90cd6a61c4f34f657f40c9",
"assets/assets/fonts/Shabnam-Medium.ttf": "94798c76cb13deef9315f622c1541d52",
"assets/assets/fonts/Shabnam-Thin.ttf": "a26aa140b7b5e9f25929a970d22bfaa2",
"assets/assets/fonts/Shabnam.ttf": "7b18a4a8f65b3f5eac92df3c91fe4400",
"assets/assets/icons/add_icon.svg": "72c431aef9197a5fa992fbf5d051a58b",
"assets/assets/icons/add_photo_icon.svg": "78c6345f19ce7dbddb2d19cf505d1c30",
"assets/assets/icons/calendar_filled_icon.svg": "ffeb95754c2b136991d43d9617ecc2f7",
"assets/assets/icons/calendar_icon.svg": "421203ec597a6adc4dff33e65740ce6b",
"assets/assets/icons/check_all_icon.svg": "79d5b399f7f62ff0f7ad9a7520349763",
"assets/assets/icons/clock_filled_icon.svg": "e3435d20160e6e892634bdad839cc880",
"assets/assets/icons/clock_icon.svg": "2bc50dd95ab80a5c5c8f7c3d369d8df4",
"assets/assets/icons/color_palette_icon.svg": "f53d6cb82eba7623d8b53528835ea839",
"assets/assets/icons/delete_icon.svg": "9ca543f82ce0e51f0468737a49ac8543",
"assets/assets/icons/drowp_down_icon.svg": "ce37e20a8022c17bf003a2eba1cca135",
"assets/assets/icons/edit_filled_icon.svg": "6bdc8357f2a86b61fe76fa1910a2d227",
"assets/assets/icons/edit_icon.svg": "9e25455fe2f8ba3283a5053ac809d7a9",
"assets/assets/icons/filter_icon.svg": "06fa068997f9cdb42a588d8c7bb2b857",
"assets/assets/icons/home_filled_icon.svg": "95eeee6ca2481ac7d940358b7cb2bdbd",
"assets/assets/icons/home_icon.svg": "e667f7d55f51d611cdbaf1c12ccc845d",
"assets/assets/icons/image_icon.svg": "49a6b42194eac0a6e2be7e5eee60757d",
"assets/assets/icons/light_mode_icon.svg": "08365a7f12eca33b4e0c619aba6d07d5",
"assets/assets/icons/night_mode_icon.svg": "213d9dda2da3d7feb32e6b776a6141d5",
"assets/assets/icons/play_icon.svg": "26dcfd0860578cfcab18b634b8d5bfa3",
"assets/assets/icons/search_icon.svg": "9a531565516490bc54746e644ad550ad",
"assets/assets/icons/sort_asc_icon.svg": "5ed12f936a59992f618f06ca05b875d8",
"assets/assets/icons/system_settings_icon.svg": "9c965cf757e785955a393762ece6ec0c",
"assets/assets/icons/upload_photo_icon.svg": "5baa9d091a2954c3834b9be6651ccdfe",
"assets/assets/images/coding_image.png": "6699b9c60f63aa43e053095f658547fc",
"assets/assets/images/exercise.png": "75995e49fe3f803664f569d0760cc63a",
"assets/assets/images/shopping.png": "80c095de6071acffb8140f577cee21a3",
"assets/assets/images/study.png": "f1826d774dcd538707baff87ac9a376d",
"assets/assets/images/studying_image.png": "3f03699758a2670e146afa26b0d465f2",
"assets/assets/images/teaching_image.png": "08b54d7b97dc285cc0ebf7867e19e08d",
"assets/FontManifest.json": "16084cf0432f9bcd10576d70d083e9c0",
"assets/fonts/MaterialIcons-Regular.otf": "074b34b13fe74abe328e83d63134855c",
"assets/NOTICES": "b91121d3046d696323151dd6ae22c526",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "89e5ed7449900dc5a5dc8fa0b1457ee9",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "be5083f54d10b9539eac3e3a7bf6e915",
"/": "be5083f54d10b9539eac3e3a7bf6e915",
"main.dart.js": "04b48e51e59b7ef687168e7b2ced2a1a",
"manifest.json": "7f8528b7961dae06f07b9b132ae162a5",
"version.json": "2e072309f8a2ca60c315c5ebf8554b6d"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
