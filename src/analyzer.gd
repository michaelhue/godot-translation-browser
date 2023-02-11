class_name Analyzer
extends Object
## Analyzes [TranslationManager] sets by comparing their translations.
##
## The analyzer is used to find discrepancies between two sets of translations.
## Given a list of message ids, two [TranslationManager] instances and an
## optional fallback locale, it will iterate of every message id for each locale
## and compare the translations. The result will be emitted via [signal result].
##
## Based on the amount of locales and messages, the process can take a few
## seconds. A separate thread is used to prevent locking the main thread.


## Emitted on each iteration of the analyziation process.
# warning-ignore:unused_signal
signal progress(percent)

## Emitted when analyzation has finished.
# warning-ignore:unused_signal
signal result(result)

## Maximum number of missing message ids including in results (per locale).
const MAX_RESULT_MESSAGES := 50

var mutex: Mutex
var thread: Thread

var _abort := false


func _init() -> void:
	mutex = Mutex.new()
	thread = Thread.new()


func _notification(type: int) -> void:
	if type == NOTIFICATION_PREDELETE:
		abort()


## Start the analyzing process with the given data. Will abort an already
## running process if necessary.
func start(
		msgids: PoolStringArray,
		a: TranslationManager,
		b: TranslationManager,
		fallback_locale := "") -> int:
	if thread.is_active():
		abort()

	var request = Request.new()
	request.msgids = msgids
	request.a = a
	request.b = b
	request.fallback_locale = fallback_locale

	return thread.start(self, "_analyze_thread", request)


## Abort an active analyzing process and wait for the thread to finish.
func abort() -> void:
	if thread.is_alive():
		mutex.lock()
		_abort = true
		mutex.unlock()

	if thread.is_active():
		thread.wait_to_finish()


## Check if the analyzer is currently working.
func is_working() -> bool:
	return thread.is_alive()


# Start the analyzing process thread. The thread will emit [signal progress]
# signals for each iteration. When the process is finished or aborted, it will
# emit [signal result] with [class Result] data.
func _analyze_thread(request: Request) -> void:
	var msgids := request.msgids
	var fallback_locale := request.fallback_locale
	var a := request.a
	var b := request.b

	var result := Result.new()
	var locales := request.a.get_sorted_locales()

	var iterations_total := msgids.size() * locales.size()
	var iteration := 0

	call_deferred("emit_signal", "progress", 0)

	for locale in locales:
		var loc_result := LocaleResult.new()
		var loc_messages := PoolStringArray()

		for msgid in msgids:
			iteration += 1

			# START abort check
			mutex.lock()
			var should_abort := _abort
			_abort = false
			mutex.unlock()

			if should_abort:
				call_deferred("emit_signal", "progress", 0)
				call_deferred("emit_signal", "result", result)
				return
			# END abort check

			var msg_a := a.translate(msgid, locale, fallback_locale)
			var msg_b := b.translate(msgid, locale, fallback_locale)

			loc_result.total += 1

			if msg_a != msg_b:
				loc_result.errors += 1

				if loc_messages.size() < MAX_RESULT_MESSAGES:
					loc_messages.append(msgid)

			call_deferred("emit_signal", "progress",
				float(iteration) / iterations_total * 100)

		loc_result.locale = locale
		loc_result.messages = loc_messages

		result.total += 1
		result.errors += 1 if loc_result.errors else 0
		result.locales.append(loc_result)

	result.finished = true

	call_deferred("emit_signal", "result", result)


## Data object for an analyzation request.
class Request extends Object:
	var msgids: PoolStringArray
	var a: TranslationManager
	var b: TranslationManager
	var fallback_locale: String


## Data object emitted via [signal result].
class Result extends Object:
	var finished := false
	var total := 0
	var errors := 0
	var locales := Array()


## Data object with results for a single locale.
class LocaleResult extends Object:
	var total := 0
	var errors := 0
	var locale: String
	var messages: PoolStringArray
