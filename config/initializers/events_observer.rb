events_observer_debit_canceled = Dune::Balanced::EventsObserver::DebitCanceled.new
Dune::Balanced::Event.add_observer(events_observer_debit_canceled, :perform)
