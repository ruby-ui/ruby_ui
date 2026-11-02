import {
  ChevronDownIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  ChevronsLeftIcon,
  ChevronsRightIcon,
  Columns3Icon,
} from "lucide-react"
import { useState } from "react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"

// JSX and classes from bases/base/blocks/dashboard-01/components/data-table.tsx,
// without drag-and-drop, tabs, the drawer and the inline target/limit inputs.
const rows = [
  { id: 1, header: "Cover page", type: "Cover page", status: "In Process", reviewer: "Eddie Lake" },
  { id: 2, header: "Table of contents", type: "Table of contents", status: "Done", reviewer: "Eddie Lake" },
  { id: 3, header: "Executive summary", type: "Narrative", status: "Done", reviewer: "Jamik Tashpulatov" },
]
const toggles = ["Type", "Status", "Reviewer"]

export default function DataTableFixture() {
  const [selected, setSelected] = useState<number[]>([])
  const [visible, setVisible] = useState<Record<string, boolean>>({ Type: true, Status: true, Reviewer: true })
  const [pageSize, setPageSize] = useState("10")
  const all = selected.length === rows.length
  const some = selected.length > 0 && !all

  return (
    <div className="flex w-full flex-col justify-start gap-6 p-6">
      <div className="flex items-center justify-between">
        <div />
        <div className="flex items-center gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger render={<Button variant="outline" size="sm" />} data-audit-trigger="">
              <Columns3Icon data-icon="inline-start" />
              Columns
              <ChevronDownIcon data-icon="inline-end" />
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-32">
              {toggles.map((column) => (
                <DropdownMenuCheckboxItem
                  key={column}
                  className="capitalize"
                  checked={visible[column]}
                  onCheckedChange={(value) => setVisible({ ...visible, [column]: !!value })}
                >
                  {column}
                </DropdownMenuCheckboxItem>
              ))}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
      <div className="relative flex flex-col gap-4 overflow-auto">
        <div className="overflow-hidden rounded-lg border">
          <Table>
            <TableHeader className="sticky top-0 z-10 bg-muted">
              <TableRow>
                <TableHead>
                  <div className="flex items-center justify-center">
                    <Checkbox
                      checked={all}
                      indeterminate={some}
                      onCheckedChange={(value) => setSelected(value ? rows.map((r) => r.id) : [])}
                      aria-label="Select all"
                    />
                  </div>
                </TableHead>
                <TableHead>Header</TableHead>
                {visible.Type && <TableHead>Type</TableHead>}
                {visible.Status && <TableHead>Status</TableHead>}
                {visible.Reviewer && <TableHead>Reviewer</TableHead>}
              </TableRow>
            </TableHeader>
            <TableBody className="**:data-[slot=table-cell]:first:w-8">
              {rows.map((row) => (
                <TableRow key={row.id} data-state={selected.includes(row.id) ? "selected" : undefined}>
                  <TableCell>
                    <div className="flex items-center justify-center">
                      <Checkbox
                        checked={selected.includes(row.id)}
                        onCheckedChange={(value) =>
                          setSelected(value ? [...selected, row.id] : selected.filter((id) => id !== row.id))
                        }
                        aria-label="Select row"
                      />
                    </div>
                  </TableCell>
                  <TableCell>{row.header}</TableCell>
                  {visible.Type && (
                    <TableCell>
                      <div className="w-32">
                        <Badge variant="outline" className="px-1.5 text-muted-foreground">
                          {row.type}
                        </Badge>
                      </div>
                    </TableCell>
                  )}
                  {visible.Status && (
                    <TableCell>
                      <Badge variant="outline" className="px-1.5 text-muted-foreground">
                        {row.status}
                      </Badge>
                    </TableCell>
                  )}
                  {visible.Reviewer && <TableCell>{row.reviewer}</TableCell>}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
        <div className="flex items-center justify-between px-4">
          <div className="hidden flex-1 text-sm text-muted-foreground lg:flex">
            {selected.length} of {rows.length} row(s) selected.
          </div>
          <div className="flex w-full items-center gap-8 lg:w-fit">
            <div className="hidden items-center gap-2 lg:flex">
              <Label htmlFor="rows-per-page" className="text-sm font-medium">
                Rows per page
              </Label>
              <Select
                value={pageSize}
                onValueChange={(value) => setPageSize(String(value))}
                items={[5, 10, 25, 50].map((size) => ({ label: `${size}`, value: `${size}` }))}
              >
                <SelectTrigger size="sm" className="w-20" id="rows-per-page">
                  <SelectValue placeholder={pageSize} />
                </SelectTrigger>
                <SelectContent side="top">
                  <SelectGroup>
                    {[5, 10, 25, 50].map((size) => (
                      <SelectItem key={size} value={`${size}`}>
                        {size}
                      </SelectItem>
                    ))}
                  </SelectGroup>
                </SelectContent>
              </Select>
            </div>
            <div className="flex w-fit items-center justify-center text-sm font-medium">Page 1 of 3</div>
            <div className="ml-auto flex items-center gap-2 lg:ml-0">
              <Button variant="outline" className="hidden h-8 w-8 p-0 lg:flex" disabled>
                <span className="sr-only">Go to first page</span>
                <ChevronsLeftIcon />
              </Button>
              <Button variant="outline" className="size-8" size="icon" disabled>
                <span className="sr-only">Go to previous page</span>
                <ChevronLeftIcon />
              </Button>
              <Button variant="outline" className="size-8" size="icon">
                <span className="sr-only">Go to next page</span>
                <ChevronRightIcon />
              </Button>
              <Button variant="outline" className="hidden size-8 lg:flex" size="icon">
                <span className="sr-only">Go to last page</span>
                <ChevronsRightIcon />
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
