import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../flutter_event_calendar.dart';

import '../providers/calendars/calendar_provider.dart';
import '../providers/instance_provider.dart';
import '../widgets/calendar_daily.dart';
import '../widgets/calendar_monthly.dart';
import '../widgets/events.dart';
import '../widgets/header.dart';

typedef CalendarChangeCallback = Function(CalendarDateTime);

class EventCalendar extends StatefulWidget {
  static late CalendarProvider calendarProvider;
  static late CalendarDateTime? dateTime;
  static late List<Event> events;
  static List<Event> selectedEvents = [];

  // static late HeaderMonthStringTypes headerMonthStringType;
  // static late HeaderWeekDayStringTypes headerWeekDayStringType;
  static late String calendarLanguage;
  static CalendarType? calendarType;

  CalendarChangeCallback? onChangeDateTime;
  CalendarChangeCallback? onMonthChanged;
  CalendarChangeCallback? onYearChanged;
  CalendarChangeCallback? onDateTimeReset;
  VoidCallback? onInit;

  List<CalendarDateTime> specialDays;

  CalendarOptions? calendarOptions;

  DayOptions? dayOptions;

  EventOptions? eventOptions;

  bool showLoadingForEvent;

  HeaderOptions? headerOptions;

  Widget? Function(CalendarDateTime)? middleWidget;

  EventCalendar({
    GlobalKey? key,
    List<Event>? events,
    CalendarDateTime? dateTime,
    this.middleWidget,
    this.calendarOptions,
    this.dayOptions,
    this.eventOptions,
    this.headerOptions,
    this.showLoadingForEvent = false,
    this.specialDays = const [],
    this.onChangeDateTime,
    this.onMonthChanged,
    this.onDateTimeReset,
    this.onInit,
    this.onYearChanged,
    required calendarType,
    calendarLanguage,
  }) : super(key: key) {
    calendarOptions ??= CalendarOptions();
    headerOptions ??= HeaderOptions();
    eventOptions ??= EventOptions();
    dayOptions ??= DayOptions();

    if (calendarType != EventCalendar.calendarType) {
      EventCalendar.calendarProvider = createInstance(calendarType);
    }
    if (key?.currentContext == null ||
        calendarType != EventCalendar.calendarType) {
      EventCalendar.dateTime = dateTime ?? calendarProvider.getDateTime();
    }
    EventCalendar.calendarType = calendarType ?? CalendarType.GREGORIAN;
    EventCalendar.calendarLanguage = calendarLanguage ?? 'en';
    EventCalendar.events = events ?? [];
  }

  static void init({
    required CalendarType calendarType,
    CalendarDateTime? dateTime,
    String? calendarLanguage,
  }) {
    EventCalendar.calendarProvider = createInstance(calendarType);
    EventCalendar.dateTime =
        dateTime ?? EventCalendar.calendarProvider.getDateTime();
    EventCalendar.calendarType = calendarType;
    EventCalendar.calendarLanguage = calendarLanguage ?? 'en';
  }

  @override
  _EventCalendarState createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  @override
  void initState() {
    widget.onInit?.call();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildScopeModels(
      child: (context) {
        return Column(
          children: [
            Card(
              color: CalendarOptions.of(context).headerMonthBackColor,
              shadowColor: CalendarOptions.of(context).headerMonthShadowColor,
              shape: CalendarOptions.of(context).headerMonthShape,
              elevation: CalendarOptions.of(context).headerMonthElevation,
              child: Column(
                children: [
                  Header(
                    onDateTimeReset: () {
                      widget.onDateTimeReset?.call(EventCalendar.dateTime!);
                      setState(() {});
                    },
                    onMonthChanged: () {
                      widget.onMonthChanged?.call(EventCalendar.dateTime!);
                      setState(() {});
                    },
                    onViewTypeChanged: () {
                      setState(() {});
                    },
                    onYearChanged: () {
                      widget.onYearChanged?.call(EventCalendar.dateTime!);
                      setState(() {});
                    },
                  ),
                  isMonthlyView()
                      ? CalendarMonthly(
                          specialDays: widget.specialDays,
                          onCalendarChanged: () {
                            widget.onChangeDateTime
                                ?.call(EventCalendar.dateTime!);
                            setState(() {});
                          })
                      : CalendarDaily(
                          specialDays: widget.specialDays,
                          onCalendarChanged: () {
                            widget.onChangeDateTime
                                ?.call(EventCalendar.dateTime!);
                            setState(() {});
                          }),
                ],
              ),
            ),
            if (widget.middleWidget != null)
              widget.middleWidget!.call(EventCalendar.dateTime!)!,
            Events(onEventsChanged: () {
              widget.onChangeDateTime?.call(EventCalendar.dateTime!);
              setState(() {});
            }),
          ],
        );
      },
    );
  }

  isMonthlyView() {
    return widget.calendarOptions?.viewType == ViewType.MONTHLY;
  }

  buildScopeModels({required WidgetBuilder child}) {
    return ScopedModel<CalendarOptions>(
      model: widget.calendarOptions!,
      child: ScopedModel<DayOptions>(
        model: widget.dayOptions!,
        child: ScopedModel<EventOptions>(
          model: widget.eventOptions!,
          child: ScopedModel<HeaderOptions>(
            model: widget.headerOptions!,
            child: Builder(builder: child),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    /// reset date time after disposing child
    EventCalendar.dateTime = EventCalendar.calendarProvider.getDateTime();
    // EventCalendar.dateTime = null;
    super.dispose();
  }
}
