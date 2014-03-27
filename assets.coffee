class Assets

  @storagePrefix: "assets-"
  @defaultExpiration = 5000

  @get: (url, options, cb) =>
    obj =
      url: url
      key: if options.key? then options.key else url.split("/").pop().split("?")[0]
      
    try
      item = localStorage.getItem(@storagePrefix + obj.key)
      throw new Error "Invalid item" unless item
      cached = JSON.parse(item or 'false')
      if obj.url is cached.url
        cb cached
      else
        throw new Error "New item" unless item
    catch e
      xhr = new XMLHttpRequest()
      xhr.open 'GET', url

      xhr.onreadystatechange = =>
        if xhr.readyState == 4
          return new Error xhr.statusText unless xhr.status == 200
          now = +new Date()
          obj.data = xhr.responseText
          obj.stamp = now
          obj.expire = now + (options.expire or @defaultExpiration) * 60 * 60 * 1000
          @save(obj, cb)
      xhr.send()

  @save: (obj, cb=null) =>
    try
      localStorage.setItem(@storagePrefix + obj.key, JSON.stringify(obj))
      return cb?(obj)
    catch e
      return cb?(obj) if e.name.toUpperCase().indexOf('QUOTA') < 0
      tempScripts = []

      for item in localStorage
        if item.indexOf(@storagePrefix) == 0
          tempScripts.push(JSON.parse(localStorage[item]))

      return false if tempScripts.length < 1

      tempScripts.sort (a, b) -> a.stamp - b.stamp
      @remove(tempScripts[0].key)

      return @save obj, cb

  @javascript: (url, options={}) =>
    if Object.prototype.toString.call(url) is '[object Array]'
      for single in url
        @javascript single, options
      return
    url = url.match /src="[^"]+"/ if url[0...6] is "<script"
    head = document.head || document.getElementsByTagName('head')[0]
    script = document.createElement('script')
    script.typel = "text/javascript"
    script.defer = true
    @get url, options, (obj) ->
      script.text = obj.data
      script.setAttribute 'id', "assets-#{obj.key.replace(".", "_")}"
      head.appendChild script

  @css: (url, options={}) =>
    head = document.head || document.getElementsByTagName('head')[0]
    css = document.createElement('style')
    css.type = 'text/css'
    @get url, options, (obj) ->
      if css.styleSheet
        css.styleSheet.cssText = obj.data
      else
        css.appendChild(document.createTextNode(obj.data))
      css.setAttribute 'id', "assets-#{obj.key.replace(".", "_")}"
      head.appendChild css

  @remove: (key) =>
    return @ unless localStorage?
    localStorage.removeItem(@storagePrefix + key)
    @

  @clear: (expired) =>
    return @ unless localStorage?
    now = +new Date()

    for item in localStorage
      key = item.split(storagePrefix)[1]
      if key and not expired or @get(key).expire <= now
        @remove key
    @

extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

window.Assets = Assets
