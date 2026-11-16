---
name: dotkernel-input-validation
description: >
  Use when you handle incoming data in a Dotkernel project: writing or changing an
  InputFilter, an Input class, or a laminas-form Form, wiring validators, filters and error
  messages, handling CSRF on a templated project, validating uploads, or deciding where a value
  should be checked. Also use when a write endpoint accepts data it should reject, when
  validation messages are inconsistent, or when a form redisplays without its errors.
---

# Input validation and forms

```text
Applies to
  Projects:  - Dotkernel API
             - Dotkernel Admin
             - Dotkernel Frontend
  Packages:  - none
```

**Never trust input.**
No data from the request goes to a service, an entity or a query builder before validation.

The mechanism depends on the variant (`dotkernel-project-variants`):

| Variant | Mechanism |
| --- | --- |
| API | `laminas/laminas-inputfilter` |
| Admin / Frontend | `laminas/laminas-form`: objects for elements, a wrapper around an InputFilter, plus CSRF |

The stock Light accepts no input, and the stock Queue validates no request data.
If you add input or request data to one of them, use an InputFilter.

## InputFilters (every variant)

```text
src/<Module>/src/InputFilter/
├── Input/TitleInput.php                extends Laminas\InputFilter\Input
├── CreateBookInputFilter.php           extends the repo's AbstractInputFilter
└── UpdateBookInputFilter.php
```

An Input class owns one field.
It attaches **both** a filter chain and a validator chain:

```php
class TitleInput extends Input
{
    public const TITLE_MAX_LENGTH = 191;

    public function __construct(?string $name = null, bool $isRequired = true)
    {
        parent::__construct($name);
        $this->setRequired($isRequired);

        $this->getFilterChain()
            ->attachByName(StringTrim::class)
            ->attachByName(StripTags::class);

        $this->getValidatorChain()
            ->attachByName(NotEmpty::class, ['message' => Message::VALIDATOR_REQUIRED_FIELD], true)
            ->attachByName(StringLength::class, [
                'max'     => self::TITLE_MAX_LENGTH,
                'message' => Message::validatorLengthMax(self::TITLE_MAX_LENGTH),
            ], true);
    }
}
```

Rules:

- Before you write a new Input class, use a shared Input class from the `App` module of the project if one applies.
  API and Admin have shared Input classes for email, password, UUID, image, identity and more.
- The `max` length must match the column length of the entity.
  If the two values are different, a long input causes a 500.
- Messages come from the constants of the shared message catalogue.
  Never use inline strings.
- The `true` third argument stops the chain on failure, so one field gives one message.
- For nested structures, use `CollectionInputFilter` or a child InputFilter that you add under a key.
- Document the validated shape with `@phpstan-type` on the filter, so that phpstan can narrow it.

## Using an InputFilter (API style)

```php
$this->inputFilter->setData((array) $request->getParsedBody());
if (! $this->inputFilter->isValid()) {
    throw BadRequestException::create(
        detail: Message::VALIDATOR_INVALID_DATA,
        additional: ['errors' => $this->inputFilter->getMessages()]
    );
}
$data = (array) $this->inputFilter->getValues();   // never getRawValues()
```

`getValues()` returns filtered values.
`getRawValues()` bypasses the filter chain, so the filters have no effect.

## Forms (Admin / Frontend)

`laminas-form` gives a thin object layer over elements, an InputFilter for each input, and data binding to and from the form.
It integrates with the Laminas security packages: `laminas-escaper`, `laminas-validator`, `laminas-filter` and `laminas-session`.
Thus, validation, filtering and rendering apply escaping by design.

- Write one `Form` class for each use case, in `src/<Module>/src/Form/`.
- Attach the InputFilter, and do not declare validators inline.
  Then a CLI command or an API can use the same rules again.
- **Each form needs a CSRF element**, and the handler must validate it.
  A form without CSRF is a vulnerability, not a simplification.
- On failure, render the same template again with the bound form.
  Then the user sees their input and the messages.
  Do not redirect, because a redirect loses them.
- Escaping is the job of the view layer.
  Never build HTML in a handler or a service.

## Query parameters are input too

Sort, filter, pagination and search values arrive without validation.
**Whitelist the sortable and filterable columns against an explicit array** before the values go to a query builder.
Clamp `limit` to a maximum.
A `sort` value without a whitelist is an injection and enumeration risk, not a style detail.

## Uploads

Validate the MIME type and the size with the shared image or file Input.
Do not store the file in a web-executable path.
Never trust the filename or the extension from the client.

## Checklist

- [ ] Each write path validates before any business logic runs.
- [ ] The Input `max` lengths match the column lengths of the entity.
- [ ] Messages come from the shared catalogue.
- [ ] The code uses `getValues()`, not `getRawValues()`.
- [ ] The CSRF element is present and validated (templated projects).
- [ ] A failed form renders again with the bound form and the messages.
- [ ] Sort, filter and limit values are whitelisted and clamped.
- [ ] Uploads are checked for type and size.
- [ ] The validated shape has a type for phpstan.
