// One code block with a copy button (CodeBlockActions as a direct child, so
// it floats top-right like RubyUI's), no header/footer. Plain text, no highlighter.
import {
  CodeBlock,
  CodeBlockActions,
  CodeBlockContent,
  CodeBlockCopyButton,
} from "@/components/ui/code-block"

const code = `$ pnpm add ai zod
dependencies:
+ ai 6.0.12
+ zod 4.1.12
Done in 2.8s
`

export default function CodeblockFixture() {
  return (
    <div className="w-[32rem] p-6">
      <CodeBlock>
        <CodeBlockActions>
          <CodeBlockCopyButton value={code} />
        </CodeBlockActions>
        <CodeBlockContent>{code}</CodeBlockContent>
      </CodeBlock>
    </div>
  )
}
