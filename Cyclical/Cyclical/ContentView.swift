//
//  ContentView.swift
//  Cyclical
//
//  Created by Taylor Carreiro on 2025-10-31.
//

import SwiftUI //this imports the SwiftUI framework, provides all the tools for building declarative user interfaces

struct CalendarView: View { //defines a new SwiftUI view called CalendarView
    //ever SwiftUI screen or component is a struct that conforms to the View protocol
    var calendar: Calendar {
        let cal = Calendar.current //creates a calendar instance using the current systems settings (e.g gregorian calendar) this helps to get dates, months and day components easily
        return cal
    }//var cal brace end
    
    //State variables
    @State private var currentDate = Date() //declares a state variable that holds the currently displayed month (init to today)
    //@state means that if currentDate changes, the view automatically updates
    @State private var selectedDate: Date? = nil
    @State private var showAddEventSheet = false
    @State private var newEventText = ""
    @State private var events: [Date: [String]] = [:] //store events by date
    @State private var isOn = false
    
    var body: some View { //body property defines what appears on screen - the UI layout of the view
        VStack { //"Vertical Stack" it lays out it its child views (text, grids etc) vertically
            //Header with month, year and nav buttons
            HStack{
                Button(action: {
                    //go to previous month
                    if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate){
                        currentDate = previousMonth
                    }
                }){
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(.horizontal)
                }
                Spacer()
                
                Text(monthYearString(from: currentDate))//displays the name of the current month and year
                //"monthYearString(from:)" function formats the date into that readable form
                    .font(.title).bold()//sets font size/style for text and padding adds space around the text so it isnt cramped against other elements
                Spacer()
                
                Button(action: {
                    //go to future month
                    if let previousMonth = calendar.date(byAdding: .month, value: 1, to: currentDate){
                        currentDate = previousMonth
                    }
                }){
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .padding(.horizontal)
                }
            }//hstack brace end
            .padding(.top)
            
            Divider()
                .padding(.bottom, 5)
            
            //weekday labels
            let weedaySymbols = calendar.shortWeekdaySymbols
            HStack{
                ForEach(weedaySymbols, id: \.self) { day in
                    Text(day.prefix(2)) //Su, Mo, etc
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    
                }
            }
            //calendar grid
            let days = generateDays(for: currentDate) //calls the helper func generateDays to get an array of all the dates in the current month, this is used to build the calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) { //creates a grid layout with 7 flexible columns, one for each day of the week
                //LazyVGrid automatically arranges its child vies into rows and columns
                ForEach(days, id: \.self) { date in //loops through each day (a Date) in the days array, for every date it builds a small text view showing the day number
                    VStack{
                        Text(dayString(from: date)) //displays the day of the month (1,2,3,...), the helper func dayString(from:) extracts just the day component from a full Date
                            .font(.body)
                            .foregroundColor(.primary)
                        //checkmark if the day has period marker
                        if let dayEvents = events[calendar.startOfDay(for: date)], dayEvents.contains("✓"){
                            Image(systemName: "drop.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        
                    }
                    
                        .frame(maxWidth: .infinity, minHeight: 40)//ensures each day cell stretches evenly across available space and has a minimum height
                        .background(calendar.isDateInToday(date) ? Color.blue.opacity(0.2) : Color.clear)//checks if it is today and if it is the background becomes blue if not then no colour assigned
                        .clipShape(RoundedRectangle(cornerRadius: 6))//rounds the corners of the background
                        .onTapGesture { //when a date is clicked show the event form
                            selectedDate = date
                            showAddEventSheet = true
                        }//on tap brace
                }//for each brace
                
            }//lazy vgrid
            Spacer() //pushes to top
        
        
        .padding() //padding around the entire calendar for spacing between screen edges
        
        //event list for selected date
        if let selectedDate = selectedDate {
            let dateString = dayMonthYearString(from: selectedDate)
            VStack(alignment: .leading){
                Text("Events for \(dateString):")
                    .font(.headline)
                if let dayEvents = events[selectedDate], !dayEvents.isEmpty {
                    ForEach(dayEvents, id: \.self) { event in
                        Text("• \(event)")
                            .padding(.leading)
                    }
                } else {
                    Text("No events scheduled for this day.")
                        .foregroundColor(.gray)
                        .padding(.leading)
                }//else brace
            }//vstack
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }//selected date brace
        }//vstack brace (main)
            
        //add event sheet
        //the event thing needs to be attached to the main vstack
            .sheet(isPresented: $showAddEventSheet) {
                VStack(spacing: 20){
                    Text("Has your period started?")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    
                    HStack(spacing: 40){
                        Button("No"){
                            showAddEventSheet = false
                        }
                        .font(.title3)
                        .foregroundColor(.red)
                        .bold()
                                                
                        Button("Yes"){
                            if let date = selectedDate {
                                let normalizedDate = calendar.startOfDay(for: date)
                                //mark next 5? days
                                for offset in 0...5 {
                                    if let nextDate = calendar.date(byAdding: .day, value: offset, to: normalizedDate){
                                        events[calendar.startOfDay(for: nextDate), default: []].append("✓")
                                    }
                                }
                                
                            }
                            showAddEventSheet = false
                            
                        }
                        .bold()
                    }
                    .padding(.horizontal)
                    Spacer()
                }//end of sheet vstack
                .presentationDetents([.medium])
                .padding()
            }//end of sheet
    }//end of body
        //helper functions
        
        //helper function that returns a string "MONTH YEAR" for given date
        func monthYearString(from date: Date) -> String {
            let formatter = DateFormatter() //convert date to readable format
            formatter.dateFormat = "LLLL yyyy" //LLLL is full month name and yyyy is 4 digit year
            return formatter.string(from: date) //return formatted string
        }
        
        func dayMonthYearString(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        
        //creates an array of Date objects representing everyday in the given month
        func generateDays(for date: Date) -> [Date] { //
            guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] } //returns the start and end of the month that date belongs to
            var days: [Date] = []
            var day = monthInterval.start
            //adjust for weekday alignment
            let firstDayWeekday = calendar.component(.weekday, from: monthInterval.start)
            let weekdayOffset = (firstDayWeekday - calendar.firstWeekday + 7) % 7
            for _ in 0..<weekdayOffset {
                days.append(Date.distantPast)//placeholders for empty cells
            }
            while day < monthInterval.end { //loops through everyday from the first to the last day of the month
                days.append(day)
                day = calendar.date(byAdding: .day, value: 1, to: day)! //adds 1 day each iteration to move to the next date , appends each day to the array
            }
            return days //returns it
        }
        
        //extracts just the day number from a Date
        func dayString(from date: Date) -> String {
            if date == Date.distantPast { return " " } //empty cell
            let day = calendar.component(.day, from: date)
            return "\(day)"
        }
        
       
            
        
    }//end of view

//this is a preview provider, used in xcodes canvas preview panel so you can see CalendarView in real time without running the full app
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View{
        CalendarView()
    }
    
}
