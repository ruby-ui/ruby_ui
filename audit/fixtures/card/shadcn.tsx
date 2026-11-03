import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"

export default function CardFixture() {
  return (
    <Card className="w-96">
      <CardHeader>
        <CardTitle>Login to your account</CardTitle>
        <CardDescription>Enter your email below to login to your account</CardDescription>
        <CardAction>
          <button type="button">Sign up</button>
        </CardAction>
      </CardHeader>
      <CardContent>
        <p>Your account details stay private.</p>
      </CardContent>
      <CardFooter>
        <button type="button" data-audit-trigger="">Login</button>
      </CardFooter>
    </Card>
  )
}
