//
//  ContentView.swift
//  Cyclical
//
//  Created by Taylor Carreiro on 2025-10-31.
//

import SwiftUI //this imports the SwiftUI framework, provides all the tools for building declarative user interfaces

struct CalendarView: View { //defines a new SwiftUI view called CalendarView
    //ever SwiftUI screen or component is a struct that conforms to the View protocol
    let calendar = Calendar.current //creates a calendar instance using the current systems settings (e.g gregorian calendar) this helps to get dates, months and day components easily
    @State private var currentDate = Date() //declares a state variable that holds the currently displayed month (init to today)
    //@state means that if currentDate changes, the view automatically updates
    var body: some View { //body property defines what appears on screen - the UI layout of the view
        VStack { //"Vertical Stack" it lays out it its child views (text, grids etc) vertically
            Text(monthYearString(from: currentDate))//displays the name of the current month and year
            //"monthYearString(from:)" function formats the date into that readable form
                .font(.title).padding()//sets font size/style for text and padding adds space around the text so it isnt cramped against other elements
            let days = generateDays(for: currentDate) //calls the helper func generateDays to get an array of all the dates in the current month, this is used to build the calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) { //creates a grid layout with 7 flexible columns, one for each day of the week
                //LazyVGrid automatically arranges its child vies into rows and columns
                ForEach(days, id: \.self) { date in //loops through each day (a Date) in the days array, for every date it builds a small text view showing the day number
                    Text(dayString(from: date)) //displays the day of the month (1,2,3,...), the helper func dayString(from:) extracts just the day component from a full Date
                        .frame(maxWidth: .infinity, minHeight: 40)//ensures each day cell stretches evenly across available space and has a minimum height
                        .background(calendar.isDateInToday(date) ? Color.blue.opacity(0.2) : Color.clear)//checks if it is today and if it is the background becomes blue if not then no colour assigned
                        .clipShape(RoundedRectangle(cornerRadius: 6))//rounds the corners of the background
                    
                }
                
            }
        }
        .padding() //padding around the entire calendar for spacing between screen edges
    }
    //helper function that returns a string "MONTH YEAR" for given date
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter() //convert date to readable format
        formatter.dateFormat = "LLLL yyyy" //LLLL is full month name and yyyy is 4 digit year
        return formatter.string(from: date) //return formatted string
    }
    
    //creates an array of Date objects representing everyday in the given month
    func generateDays(for date: Date) -> [Date] { //
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] } //returns the start and end of the month that date belongs to
        var days: [Date] = []
        var day = monthInterval.start
        while day < monthInterval.end { //loops through everyday from the first to the last day of the month
            days.append(day)
            day = calendar.date(byAdding: .day, value: 1, to: day)! //adds 1 day each iteration to move to the next date , appends each day to the array
        }
        return days //returns it
    }
    
    //extracts just the day number from a Date
    func dayString(from date: Date) -> String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }
}

//this is a preview provider, used in xcodes canvas preview panel so you can see CalendarView in real time without running the full app
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View{
        CalendarView()
    }
}



