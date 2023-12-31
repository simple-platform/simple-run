import { CubeIcon } from '@heroicons/react/24/outline'

export default function NoProjects() {
  return (
    <section className="h-full flex flex-col items-center justify-center space-y-3">
      <CubeIcon className="w-24 h-24" />
      <h1 className="text-2xl font-semibold">Your projects will show up here</h1>
    </section>
  )
}
