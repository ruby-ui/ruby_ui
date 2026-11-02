import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from "@/components/ui/carousel"

export default function CarouselFixture() {
  return (
    <div className="p-16">
      <Carousel className="w-full max-w-xs">
        <CarouselContent>
          {["1", "2", "3", "4", "5"].map((n) => (
            <CarouselItem key={n}>
              <div className="flex aspect-square items-center justify-center rounded-lg border p-6">
                <span className="text-4xl font-semibold">{n}</span>
              </div>
            </CarouselItem>
          ))}
        </CarouselContent>
        <CarouselPrevious />
        <CarouselNext data-audit-trigger="" />
      </Carousel>
    </div>
  )
}
