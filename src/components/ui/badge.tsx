import * as React from "react"
import { cn } from "../../lib/utils"

const badgeVariants = {
  default: "bg-[#6D28D9] text-white border-transparent",
  secondary: "bg-[#F8FAFC] text-[#475569] border-[#E2E8F0]",
  destructive: "bg-[#EF4444] text-white border-transparent",
  outline: "text-[#475569] border-[#E2E8F0]",
} as const

interface BadgeProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: keyof typeof badgeVariants;
}

function Badge({ className, variant = "default", ...props }: BadgeProps) {
  return (
    <div
      className={cn(
        "inline-flex items-center rounded-md border px-2.5 py-0.5 text-xs font-medium transition-colors focus:outline-none focus:ring-0",
        badgeVariants[variant],
        className
      )}
      {...props}
    />
  )
}

export { Badge, badgeVariants }
