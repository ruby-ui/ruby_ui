// Three code blocks (strings in content.yml): a floating copy button, a
// header + footer, and numbered diff lines. Plain text, no highlighter.
import {
  CodeBlock,
  CodeBlockActions,
  CodeBlockContent,
  CodeBlockCopyButton,
  CodeBlockFooter,
  CodeBlockHeader,
  CodeBlockLine,
  CodeBlockTitle,
} from "@/components/ui/code-block"

const code = `$ pnpm add ai zod
dependencies:
+ ai 6.0.12
+ zod 4.1.12
Done in 2.8s
`

export default function CodeblockFixture() {
  return (
    <div className="flex w-[32rem] flex-col gap-4 p-6">
      <CodeBlock data-audit-trigger="">
        <CodeBlockActions>
          <CodeBlockCopyButton value={code} />
        </CodeBlockActions>
        <CodeBlockContent>{code}</CodeBlockContent>
      </CodeBlock>
      <CodeBlock>
        <CodeBlockHeader>
          <CodeBlockTitle>install.sh</CodeBlockTitle>
          <CodeBlockActions>
            <CodeBlockCopyButton value={code} />
          </CodeBlockActions>
        </CodeBlockHeader>
        <CodeBlockContent>{code}</CodeBlockContent>
        <CodeBlockFooter>Runs in the project root.</CodeBlockFooter>
      </CodeBlock>
      <CodeBlock>
        <CodeBlockContent lineNumbers>
          <CodeBlockLine variant="removed">const answer = 41</CodeBlockLine>
          <CodeBlockLine variant="added">const answer = 42</CodeBlockLine>
          <CodeBlockLine />
          <CodeBlockLine variant="highlighted">console.log(answer)</CodeBlockLine>
        </CodeBlockContent>
      </CodeBlock>
    </div>
  )
}
