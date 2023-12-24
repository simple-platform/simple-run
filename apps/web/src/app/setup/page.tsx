import { ChevronDoubleRightIcon } from '@heroicons/react/24/outline'
import { Header } from '@simple-run/ui/header'

const SetupForm: JSX.Element = (
  <section className="max-w-sm md:max-w-xl w-full mt-6 md:mt-12">
    <div className="p-3 md:px-6 md:py-6 shadow rounded-lg dark:bg-slate-800">
      <label className="label" htmlFor="github_url">
        <span className="label-text-alt">
          GitHub URL
          {' '}
          <span className="italic">( we only support public GitHub repos for now )</span>
        </span>
      </label>
      <div className="join w-full">
        <input className="input input-bordered w-full join-item" name="github_url" placeholder="https://github.com/simple-platform/simple-run" type="text" />
        <button className="btn join-item input-bordered border-l-0">
          <ChevronDoubleRightIcon className="w-6" />
        </button>
      </div>
    </div>
  </section>
)

export default function Page(): JSX.Element {
  return (
    <main className="h-full flex flex-col justify-center items-center p-6 md:p-12">
      <Header className="text-center" title="Let's setup your project to run locally!" />
      {SetupForm}
    </main>
  )
}
