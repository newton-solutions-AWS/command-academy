// app/academy/[division]/page.tsx
import { redirect } from "next/navigation";

type Props = {
  params: {
    division: string;
  };
};

export default function DivisionEntry({ params }: Props) {
  if (params.division === "phoenix") {
    redirect("/academy/phoenix/phoenix-boot-001");
  }

  // fallback for future divisions
  redirect("/academy");
}