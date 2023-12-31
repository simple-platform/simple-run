import { ArrowLongRightIcon, ClipboardDocumentListIcon, InformationCircleIcon } from '@heroicons/react/24/outline'

export default function InstallAgent() {
  const cmd = 'curl -fsSL https://simple.dev/run/install.sh | sh'

  return (
    <section className="w-full space-y-3 md:space-y-6">
      <div>
        <div className="alert alert-info text-sm rounded-md transition" role="alert">
          <InformationCircleIcon className="w-6 h-6 md:w-10 md:h-10" />
          <div>
            <div className="font-semibold">
              Simple Run installation is required.
            </div>
            <div>Please copy and paste the following code in your terminal to install Simple Run.</div>
          </div>
        </div>
      </div>
      <div className="mockup-code rounded-md">
        <pre data-prefix="~"><code>{cmd}</code></pre>
        <div className="absolute top-0 right-0">
          <ClipboardDocumentListIcon className="w-4 h-4 relative right-3 top-3 cursor-pointer text-slate-50 hover:text-orange-300 active:text-indigo-300" onClick={() => navigator.clipboard.writeText(cmd)} />
        </div>
      </div>
      <div className="text-lg flex items-center">
        I&apos;m done installing Simple Run.
        {' '}
        <button className="btn btn-sm ml-2" onClick={() => window.location.reload()}>
          Let&apos;s Continue
          <ArrowLongRightIcon className="w-4 h-4" />
        </button>
      </div>
    </section>
  )
}
