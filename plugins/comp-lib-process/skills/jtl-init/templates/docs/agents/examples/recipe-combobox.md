# Example Recipe: ComboBox

A worked Recipe showing how to compose already-installed pieces into a ComboBox.
shadcn supplies the parts (popover + command) but ships no packaged ComboBox, and
the arrangement varies per use — so this is a Recipe, not a Block. See
[../authoring/recipe.md](../authoring/recipe.md).

## Intent

A single-select ComboBox: a button that opens a searchable list in a popover.
Reach for this when a plain `Select` is not enough (the options are searchable)
but the arrangement differs per screen.

## Prerequisites

Install the atoms first:

```bash
npx shadcn@latest add popover command button
```

No external library is required for the base version. For async option loading,
add your data-fetching library of choice (for example TanStack Query) — named here
so the consumer can judge the dependency.

## Composition

```tsx
import { useState } from "react";
import { Check, ChevronsUpDown } from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";

type Option = { value: string; label: string };

export function ComboBox({
  options,
  value,
  onChange,
  label,
}: {
  options: Option[];
  value: string;
  onChange: (value: string) => void;
  label: string;
}) {
  const [open, setOpen] = useState(false);
  const selected = options.find((o) => o.value === value);

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          variant="outline"
          role="combobox"
          aria-expanded={open}
          aria-label={label}
        >
          {selected?.label ?? label}
          <ChevronsUpDown data-icon="inline-end" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="p-0">
        <Command>
          <CommandInput placeholder={`Search ${label}...`} />
          <CommandList>
            <CommandEmpty>No results.</CommandEmpty>
            <CommandGroup>
              {options.map((option) => (
                <CommandItem
                  key={option.value}
                  value={option.value}
                  onSelect={(current) => {
                    onChange(current === value ? "" : current);
                    setOpen(false);
                  }}
                >
                  {option.label}
                  <Check
                    data-icon="inline-end"
                    className={cn(
                      option.value === value ? "opacity-100" : "opacity-0",
                    )}
                  />
                </CommandItem>
              ))}
            </CommandGroup>
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  );
}
```

## Adaptation points

- Swap the trigger content for the surface's needs (avatar, badge, status dot).
- Add async loading by feeding `options` from your fetch layer; keep the input in
  the DOM while loading so keyboard use is preserved.
- Multi-select is a different arrangement — copy and adapt, do not overload this.

## Accessibility notes

- The trigger carries `role="combobox"`, `aria-expanded`, and an accessible label.
- Selection shows a check at the end and closes the popover; focus returns to the
  trigger.

## Promotion note

If a second app needs this exact arrangement with the same options contract,
promote it to an Enhanced Block (`@jtl/combo-box`) with a property API. See
[../decision-matrix.md](../decision-matrix.md).
