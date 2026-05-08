# TailwindMerge

Utility function to efficiently merge [Tailwind CSS](https://tailwindcss.com/) classes without style conflicts. Essentially, a Ruby port of [tailwind-merge](https://github.com/dcastil/tailwind-merge).

- Version 1.0 and above supports Tailwind v4.0+.
- Versions below that support from v3.0 up to v3.4.

## Installation

Install the gem and add it to your application's Gemfile by executing:

    $ bundle add tailwind_merge

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install tailwind_merge

## Usage

To use it, pass in a single string:

```ruby
require "tailwind_merge"

TailwindMerge::Merger.new.merge("px-2 py-1 bg-red hover:bg-dark-red p-3 bg-[#B91C1C]")
# → "hover:bg-dark-red p-3 bg-[#B91C1C]"
```

Or, an array of strings:

```ruby
require "tailwind_merge"

TailwindMerge::Merger.new.merge(["px-2 py-1", "bg-red hover:bg-dark-red", "p-3 bg-[#B91C1C]"])
# → "hover:bg-dark-red p-3 bg-[#B91C1C]"
```

## What's it for?

If you use Tailwind with a component-based UI renderer (like [ViewComponent](https://viewcomponent.org)), you're probably familiar with the situation that you want to change some styles of an existing component:

```html
<!-- app/components/confirm_email_component.html.erb -->
<div class="border rounded px-2 py-1">Please confirm your email address.</div>
```

```ruby
<%= render(ConfirmEmailComponent.new(class: "p-5")) %>
```

When the `ConfirmEmailComponent` is rendered, an input with the className `border rounded px-2 py-1` gets created. But because of the way the [CSS cascade](https://developer.mozilla.org/en-US/docs/Web/CSS/Cascade) works, the styles of the `p-5` class are ignored. The order of the classes in the `class` string doesn't matter at all and the only way to apply the `p-5` style is to remove both `px-2` and `py-1`.

This is where `tailwind_merge` comes in:

```ruby
@merger = TailwindMerge::Merger.new
@merger.merge("border rounded px-2 py-1 p-5") # → "border rounded p-5"
```

tailwind-merge overrides conflicting classes and keeps everything else untouched. In the case of the implementation of `ConfirmEmailComponent`, the input now only renders the classes `border rounded p-5`.

## Features

### Merging behavior

`tailwind_merge` is built to be intuitive. It follows a set of rules to determine which class wins when there are conflicts. Here is a brief overview of its conflict resolution.

### Last conflicting class wins

```ruby
@merger.merge("p-5 p-2 p-4") # → "p-4"
```

### Supports refinements

```ruby
@merger.merge("p-3 px-5") # → "p-3 px-5"
@merger.merge("inset-x-4 right-4") # → "inset-x-4 right-4"
```

### Resolves non-trivial conflicts

```ruby
@merger.merge("inset-x-px -inset-1") # → "-inset-1"
@merger.merge("bottom-auto inset-y-6") # → "inset-y-6"
@merger.merge("inline block") # → "block"
```

### Supports modifiers and stacked modifiers

```ruby
@merger.merge("p-2 hover:p-4") # → "p-2 hover:p-4"
@merger.merge("hover:p-2 hover:p-4") # → "hover:p-4"
@merger.merge("hover:focus:p-2 focus:hover:p-4") # → "focus:hover:p-4"
```

The order of standard modifiers does not matter for tailwind-merge.

### Supports arbitrary values

```ruby
@merger.merge("bg-black bg-(--my-color) bg-[color:var(--mystery-var)]") # → "bg-[color:var(--mystery-var)]"
@merger.merge("grid-cols-[1fr,auto] grid-cols-2") # → "grid-cols-2"
```

> **Warning**
> Labels necessary in ambiguous cases
>
> When using arbitrary values in ambiguous classes like `text-[calc(var(--rebecca)-1rem)]` tailwind-merge looks at the arbitrary value for clues to determine what type of class it is. In this case, like in most ambiguous classes, it would try to figure out whether `calc(var(--rebecca)-1rem)` is a length (making it a font-size class) or a color (making it a text-color class). For lengths it takes clues into account like the presence of the `calc()` function or a digit followed by a length unit like `1rem`.
>
> But it isn't always possible to figure out the type by looking at the arbitrary value. E.g. in the class `text-[theme(myCustomScale.rebecca)]` tailwind-merge can't know the type of the arbitrary value and will default to a text-color class. To make tailwind-merge understand the correct type of the arbitrary value in those cases, you can use CSS data type labels [which are used by Tailwind CSS to disambiguate classes](https://tailwindcss.com/docs/adding-custom-styles#resolving-ambiguities): `text-[length:theme(myCustomScale.rebecca)]`.

### Supports arbitrary properties

```ruby
@merger.merge("[mask-type:luminance] [mask-type:alpha]") # → "[mask-type:alpha]"
@merger.merge("[--scroll-offset:56px] lg:[--scroll-offset:44px]") # → "[--scroll-offset:56px] lg:[--scroll-offset:44px]"

#Don't actually do this!
@merger.merge("[padding:1rem] p-8") # → "[padding:1rem] p-8"
```

> **Warning** > `tailwind_merge` does not resolve conflicts between arbitrary properties and their matching Tailwind classes to keep the bundle size small.

### Supports arbitrary variants

```ruby
@merger.merge("[&:nth-child(3)]:py-0 [&:nth-child(3)]:py-4") # → "[&:nth-child(3)]:py-4"
@merger.merge("dark:hover:[&:nth-child(3)]:py-0 hover:dark:[&:nth-child(3)]:py-4") # → "hover:dark:[&:nth-child(3)]:py-4"

# Don't actually do this!
@merger.merge("[&:focus]:ring focus:ring-4") # → "[&:focus]:ring focus:ring-4"
```

> **Warning**
> Similarly to arbitrary properties, `tailwind_merge` does not resolve conflicts between arbitrary variants and their matching predefined modifiers for bundle size reasons.
> The order of standard modifiers before and after an arbitrary variant in isolation (all modifiers before are one group, all modifiers after are another group) does not matter for `tailwind_merge`. However, it _does_ matter whether a standard modifier is before or after an arbitrary variant both for Tailwind CSS and `tailwind_merge` because the resulting CSS selectors are different.

### Supports important modifier

```ruby
@merger.merge("p-3! p-4! p-5") # → "p-4! p-5"
@merger.merge("right-2! -inset-x-1!") # → "-inset-x-1!"
```

## Supports postfix modifiers

```ts
twMerge("text-sm leading-6 text-lg/7"); // → "text-lg/7"
```

### Preserves non-Tailwind classes

```ruby
@merger.merge("p-5 p-2 my-non-tailwind-class p-4") # → "my-non-tailwind-class p-4"
```

### Supports custom colors out of the box

```ruby
@merger.merge("text-red text-secret-sauce") # → "text-secret-sauce"
```

## Basic usage

If you're using Tailwind CSS without any extra configs, you can use it right away:

```ruby
merger = TailwindMerge::Merger.new
```

### Usage with custom Tailwind config

If you're using a custom Tailwind config, you may need to configure `tailwind_merge` as well to merge classes properly.

The default `TailwindMerge::Merger` initializer is configured in a way that you can still use it if all the following points apply to your Tailwind config:

- Only using color names which don't clash with other Tailwind class names
- Only deviating by number values from number-based Tailwind classes
- Only using font-family classes which don't clash with default font-weight classes
- Sticking to default Tailwind config for everything else

If some of these points don't apply to you, you can test whether the merge still works as intended with your custom classes. Otherwise, you need create your own custom merge function by either extending the default tailwind-merge config or using a completely custom one.

The `tailwind_merge` config is different from the Tailwind config because it's expected to be shipped and run in the browser as opposed to the Tailwind config which is meant to run at build-time. Be careful in case you're using your Tailwind config directly to configure tailwind-merge in your client-side code because that could result in an unnecessarily large bundle size.

## Configuration

The `tailwind_merge` config is an object with several keys. All of these values are optional.

```ruby
tailwind_merge_config = {
  # Define how many values should be stored in cache.
  cache_size: 500,
  # Enable or disable caching nil values.
  ignore_empty_cache: true,
  # Prefix from your Tailwind config
  prefix: "tw",
  theme: {
    # Theme scales are defined here
    # This is not the theme object from your Tailwind config
  },
  class_groups: {
    # Class groups are defined here
  },
  conflicting_class_groups: {
    # Conflicts between class groups are defined here
  },
  # Modifiers whose order among multiple modifiers should be preserved because their
  # order changes which element gets targeted. Overrides default value.
  order_sensitive_modifiers: [],
}
```

To use the custom configuration, pass it to the `TailwindMerge::Merger` initializer:

```ruby
@merger = TailwindMerge::Merger.new(config: tailwind_merge_config)
```

### Class groups

The library uses a concept of _class groups_ which is an array of Tailwind classes which all modify the same CSS property. For example, here is the position class group:

```ruby
position_class_group = ["static", "fixed", "absolute", "relative", "sticky"]
```

`tailwind_merge` resolves conflicts between classes in a class group and only keeps the last one passed to the merge function call:

```ruby
@merger.merge("static sticky relative") # → "relative"
```

Tailwind classes often share the beginning of the class name, so elements in a class group can also be an object with values of the same shape as a class group (the shape is recursive). In the object, each key is joined with all the elements in the corresponding array with a dash (`-`) in between.

For example, here is the overflow class group which results in the classes `overflow-auto`, `overflow-hidden`, `overflow-visible` and `overflow-scroll`.

```ruby
overflow_class_group = [{ overflow: ["auto", "hidden", "visible", "scroll"] }]
```

Sometimes it isn't possible to enumerate every element in a class group. Think of a Tailwind class which allows arbitrary values. In this scenario you can use a validator function which takes a _class part_ and returns a boolean indicating whether a class is part of a class group.

For example, here is the fill class group:

```ruby
is_arbitrary_value = (class_part: string) => /^\[.+\]$/.test(class_part)
fill_class_group = [{ fill: ["current", IS_ARBITRARY_VALUE] }]
```

Because the function is under the `fill` key, it will only get called for classes which start with `fill-`. Also, the function only gets passed the part of the class name which comes after `fill-`, this way you can use the same function in multiple class groups. `tailwind_merge` provides its own [validators](#validators), so you don't need to recreate them.

You can use an empty string (`""`) as a class part if you want to indicate that the preceding part was the end. This is useful for defining elements which are marked as `DEFAULT` in the Tailwind config.

```ruby
# ↓ Resolves to filter and filter-none
filter_class_group = [{ filter: ["", "none"] }]
```

Each class group is defined under its ID in the `class_groups` object in the config. This ID is only used internally, and the only thing that matters is that it is unique among all class groups.

### Conflicting class groups

Sometimes there are conflicts across Tailwind classes which are more complex than "remove all those other classes when a class from this group is present in the class list string".

One example is the combination of the classes `px-3` (setting `padding-left` and `padding-right`) and `pr-4` (setting `padding-right`).

If they are passed to `merge` as `pr-4 px-3`, I think you most likely intend to apply `padding-left` and `padding-right` from the `px-3` class and want `pr-4` to be removed, indicating that both these classes should belong to a single class group.

But if they are passed to `merge` as `px-3 pr-4`, it's assumed you want to set the `padding-right` from `pr-4` but still want to apply the `padding-left` from `px-3`, so `px-3` shouldn't be removed when inserting the classes in this order, indicating they shouldn't be in the same class group.

To summarize, `px-3` should stand in conflict with `pr-4`, but `pr-4` should not stand in conflict with `px-3`. To achieve this, we need to define asymmetric conflicts across class groups.

This is what the `conflicting_class_groups` object in the config is for. You define a key in it which is the ID of a class group which _creates_ a conflict and the value is an array of IDs of class group which _receive_ a conflict.

```ruby
conflicting_class_groups = { px: ["pr", "pl"] }
```

If a class group _creates_ a conflict, it means that if it appears in a class list string passed to `merge`, all preceding class groups in the string which _receive_ the conflict will be removed.

When we think of our example, the `px` class group creates a conflict which is received by the class groups `pr` and `pl`. This way `px-3` removes a preceding `pr-4`, but not the other way around.

### Postfix modifiers conflicting with class groups

Tailwind CSS allows postfix modifiers for some classes. E.g. you can set font-size and line-height together with `text-lg/7` with `/7` being the postfix modifier. This means that any line-height classes preceding a font-size class with a modifier should be removed.
For this tailwind-merge has the `conflicting_class_groups` object in its config with the same shape as `conflicting_class_groups` explained in the [section above](#conflicting-class-groups). This time the key is the ID of a class group whose modifier _creates_ a conflict and the value is an array of IDs of class groups which _receive_ the conflict.

```ruby
conflicting_class_groups = {
  "font-size": ["leading"],
};
```

### Order-sensitive modifiers

In Tailwind CSS, not all modifiers behave the same when you stack them.

In most cases the order of modifiers doesn't matter. E.g. `hover:focus:bg-red-500` and `focus:hover:bg-red-500` behave the same and in the context of tailwind-merge, you'd want them both to override each other. tailwind-merge sorts the modifiers internally to be able to override classes with the same modifiers, even if they are in a different order.

However, there are some modifiers where the order matters, e.g. the direct children modifier `*`. The class `*:hover:text-red-500` modifies the text color of a child if that particular child is hovered, but the class `hover:*:text-red-500` modifies the text color of all direct children if the parent is hovered. In this case, you would want tailwind-merge to preserve both classes although they have the same modifiers, just in a different order.

To know which modifiers are order-sensitive, tailwind-merge has the `orderSensitiveModifiers` property in its config. `twMerge` is pre-configured with all the order-sensitive modifiers that Tailwind CSS has by default. You'll only need to configure this property if you add your own order-sensitive modifiers or change the meaning of the default order-sensitive modifiers.

### Theme

In the Tailwind config you can modify your theme variable namespace to add classes with custom values. tailwind-merge follows the same naming scheme as Tailwind CSS for its theme scales:

| Tailwind CSS namespace | tailwind-merge theme key |
| ---------------------- | ------------------------ |
| `--color-*`            | `color`                  |
| `--font-*`             | `font`                   |
| `--text-*`             | `text`                   |
| `--font-weight-*`      | `font-weight`            |
| `--tracking-*`         | `tracking`               |
| `--leading-*`          | `leading`                |
| `--breakpoint-*`       | `breakpoint`             |
| `--container-*`        | `container`              |
| `--spacing-*`          | `spacing`                |
| `--radius-*`           | `radius`                 |
| `--shadow-*`           | `shadow`                 |
| `--inset-shadow-*`     | `inset-shadow`           |
| `--drop-shadow-*`      | `drop-shadow`            |
| `--blur-*`             | `blur`                   |
| `--perspective-*`      | `perspective`            |
| `--aspect-*`           | `aspect`                 |
| `--ease-*`             | `ease`                   |
| `--animate-*`          | `animate`                |

If you modified one of the theme namespaces in your Tailwind config, you need to add the variable names to the `theme` object in tailwind-merge as well so that tailwind-merge knows about them.

E.g. let's say you added the variable `--text-huge-af: 100px` to your Tailwind config which enables classes like `text-huge-af`. To make sure that tailwind-merge merges these classes correctly, you need to configure tailwind-merge like this:

```ruby
merger = TailwindMerge::Merger.new(config: {
 theme: {
    # ↓ `text` is the key of the namespace `--text-*`
    #      ↓ `huge-af` is the variable name in the namespace
    text: ["huge-af"],
  }
})
```

### Validators

Here's a brief summary for each validator:

- `IS_ANY` always returns true. Be careful with this validator as it might match unwanted classes. I use it primarily to match colors or when I'm certain there are no other class groups in a namespace.
- `IS_ANY_NON_ARBITRARY` checks if the class part is not an arbitrary value or arbitrary variable.
- `IS_ARBITRARY_IMAGE` checks whether class part is an arbitrary value which is an iamge, e.g. by starting with `image:`, `url:`, `linear-gradient(` or `url(` (`[url('/path-to-image.png')]`, `image:var(--maybe-an-image-at-runtime)]`) which is necessary for background-image classNames.
- `IS_ARBITRARY_LENGTH` checks for arbitrary length values (`[3%]`, `[4px]`, `[length:var(--my-var)]`).
- `IS_ARBITRARY_NUMBER` checks whether class part is an arbitrary value which starts with `number:` or is a number (`[number:var(--value)]`, `[450]`) which is necessary for font-weight and stroke-width classNames.
- `IS_ARBITRARY_POSITION` checks whether class part is an arbitrary value which starts with `position:` (`[position:200px_100px]`) which is necessary for background-position classNames.
- `IS_ARBITRARY_SHADOW` checks whether class part is an arbitrary value which starts with the same pattern as a shadow value (`[0_35px_60px_-15px_rgba(0,0,0,0.3)]`), namely with two lengths separated by a underscore, optionally prepended by `inset`.
- `IS_ARBITRARY_SIZE` checks whether class part is an arbitrary value which starts with `size:` (`[size:200px_100px]`) which is necessary for background-size classNames.
- `IS_ARBITRARY_VALUE` checks whether the class part is enclosed in brackets (`[something]`)
- `IS_ARBITRARY_VARIABLE` checks whether the class part is an arbitrary variable (`(--my-var)`)
- `IS_ARBITRARY_VARIABLE_FAMILYNAME` checks whether class part is an arbitrary variable with the `family-name` label (`(family-name:--my-font)`)
- `IS_ARBITRARY_VARIABLE_IMAGE` checks whether class part is an arbitrary variable with the `image` or `url` label (`(image:--my-image)`)
- `IS_ARBITRARY_VARIABLE_LENGTH` checks whether class part is an arbitrary variable with the `length` label (`(length:--my-length)`)
- `IS_ARBITRARY_VARIABLE_POSITION` checks whether class part is an arbitrary variable with the `position` label (`(position:--my-position)`)
- `IS_ARBITRARY_VARIABLE_SHADOW` checks whether class part is an arbitrary variable with the `shadow` label or not label at all (`(shadow:--my-shadow)`, `(--my-shadow)`)
- `IS_ARBITRARY_VARIABLE_SIZE` checks whether class part is an arbitrary variable with the `size`, `length` or `percentage` label (`(size:--my-size)`)
- `IS_FRACTION` checks whether class part is a fraction of two numbers (`1/2`, `127/256`)
- `IS_INTEGER` checks for integer values (`3`).
- `IS_NUMBER` checks for numbers (`3`, `1.5`)
- `IS_PERCENT` checks for percent values (`12.5%`) which is used for color stop positions.
- `IS_TSHIRT_SIZE`checks whether class part is a T-shirt size (`sm`, `xl`), optionally with a preceding number (`2xl`).

## Performance

### Results are cached

Results are cached by default, so you don't need to worry about wasteful re-renders. The library uses a computationally lightweight [LRU cache](<https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_recently_used_(LRU)>) which stores up to 500 different results by default. The cache is applied after all arguments are joined together to a single string. This means that if you call `merge` repeatedly with different arguments that result in the same string when joined, the cache will be hit.

The cache size can be modified or opted out of by setting the `cache_size` config variable.

### Data structures are reused between calls

Expensive computations happen upfront so that `merge` calls without a cache hit stay fast.

### Lazy initialization

The initial computations are called lazily on the first call to `merge` to prevent it from impacting startup performance if it isn't used initially.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gjtorikian/tailwind_merge.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgements

This gem is pretty much just a port of https://github.com/dcastil/tailwind-merge. Thank them, not me!
