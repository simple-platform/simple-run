import { Square3Stack3DIcon } from '@heroicons/react/24/outline'

export default function NoApplications() {
  return (
    <section className="h-full flex flex-col items-center justify-center space-y-3">
      <Square3Stack3DIcon className="w-24 h-24" />
      <h1 className="text-2xl font-semibold">Your applications will show up here</h1>
      <div>
        Get started by clicking
        {' '}
        <span className="italic underline underline-offset-2 decoration-dotted">Run Locally</span>
        {' '}
        button on your favorite GitHub repository
      </div>
    </section>
  )
}
