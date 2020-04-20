<p align="center">
<img
src="https://s3.amazonaws.com/ryu-logos/RyuIcon128x128.png?"
width="128px;">
</p>

<h1 align="center">SwiftPromises</h1>
<p align="center">
Light-weight Promise package for Swift
</p>

[![Build Status](https://travis-ci.com/RyuGames/SwiftPromises.svg?branch=master)](https://travis-ci.com/RyuGames/SwiftPromises)
[![codecov](https://codecov.io/gh/RyuGames/SwiftPromises/branch/master/graph/badge.svg)](https://codecov.io/gh/RyuGames/SwiftPromises)
[![Version](https://img.shields.io/cocoapods/v/SwiftPromises.svg?style=flat)](https://cocoapods.org/pods/SwiftPromises)
[![License](https://img.shields.io/cocoapods/l/SwiftPromises.svg?style=flat)](./LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/SwiftPromises.svg?style=flat)](https://cocoapods.org/pods/SwiftPromises)

- [Overview](#overview)
- [Installation](#installation)
- [Example Usage](#example-usage)
  - [Creating a Promise](#creating-a-promise)
  - [Then](#then)
  - [Catch](#catch)
  - [Chaining](#chaining)
  - [All](#all)
  - [Await](#await)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

## Overview

`SwiftPromises` is a light-weight package to implement Promises in native Swift. It does not have any sub-dependencies and is meant to add Promise support with the most minimal code.

A Promise is an object representing the eventual completion/failure of an asynchronous operation. While it is available natively in some languages, it is not currently supported out of the box in Swift.

Inspired by [Pierre Felgines' article "Implementing Promises in Swift"](https://felginep.github.io/2019-01-06/implementing-promises-in-swift), [Khanlou's Promise library](https://github.com/khanlou/Promise) and [Google's Promises framework](https://github.com/google/promises).

## Installation

`SwiftPromises` is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
pod 'SwiftPromises'
```

And run ```pod install```.

## Example Usage

### Creating a Promise

The following defines a Promise that will resolve with the value `15`.

``` swift
let promise = Promise<Int> (15)

...

let promise = Promise<Int> {
  return 15
}

...

let promise = Promise<Int> { resolve, _ in
  resolve(15)
}
```

Promises can also reject with an `Error`.

``` swift
let error = NSError(domain: "Error", code: -500, userInfo: [:])

let promise = Promise<Int> (error)

...

let promise = Promise<Int> {
  return error
}

...

let promise = Promise<Int> { _, reject in
  reject(error)
}
```

### Then

The `Then` function can be used to handle a resolved Promise:

``` swift
let promise = Promise<Int> { resolve, _ in
  resolve(1)
}

promise.then { (num) in
  print(num) // Prints 1
}
```

### Catch

The `Catch` function can be used to handle a thrown error in a Promise:

``` swift
let promise = Promise<Bool> { _, reject in
  reject(NSError(domain: "Error", code: -500, userInfo: [:]))
}

promise.catch { err in
  let err = err as NSError
  let message = err.domain
  print(message) // Prints "Error"
}
```

### Chaining

Promises can be chained together:

``` swift
func work1(_ string: String) -> Promise<String> {
  return Promise { resolve, _ in
    resolve(string)
  }
}

func work2(_ string: String) -> Promise<Int> {
  return Promise { resolve, _ in
    resolve(Int(string) ?? 0)
  }
}

func work3(_ number: Int) -> Int {
  return number * number
}

work1("10").then { string in
  return work2(string)
}.then { number in
  return work3(number)
}.then { number in
  print(number) // Prints 100
}
```

### All

The `All` function can be used to call an array of Promises in parallel. `All` returns a new Promise that returns an array with resolved values. If one of the Promises in the array throws an error, `All` will call its `Catch` function.

``` swift
let promise = Promise<Int> { resolve, _ in
  resolve(15)
}

let promise2 = Promise<Int> { resolve, _ in
  resolve(4)
}

all([promise, promise2]).then { (numbers) in
  var total = 0
  for number in numbers {
      total += number
  }
  print(total) // Prints 19
}.catch { (err) in
  // Not called in this example
}
```

### Await

The `Await` function can be used to synchronously call a Promise.

``` swift
let promise = Promise<Int> { resolve, _ in
  DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
    resolve(1)
  })
}

guard let value = try? await(promise: promise) else { return }

print(value) // Prints 1 after one second has passed
```

Note that the `Await` function should only be called with global threads to prevent deadlocking.

## Contributing

We welcome contributors to `SwiftPromises`. Before beginning, please take a look at our [contributing guidelines](./CONTRIBUTING.md).

## Author

[WyattMufson](mailto:wyatt@ryu.games) - cofounder of Ryu Games

## License

`SwiftPromises` is available under the [MIT license](./LICENSE).
