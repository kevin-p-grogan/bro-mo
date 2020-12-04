//
//  ContentView.swift
//  bromo
//
//  Created by Kevin Grogan on 10/11/20.
//

import Foundation
import SwiftUI
import Combine

struct WorkoutGeneratorView: View {
    @ObservedObject var config: Configuration
    @ObservedObject var fetcher = WorkoutFetcher()
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        VStack {
            GenerationButton(fetcher: fetcher, config: config)
            ScheduleView(fetcher: fetcher, config: config).environment(\.managedObjectContext, context)
            Spacer()
        }
    }
}

struct GenerationButton: View {
    var fetcher: WorkoutFetcher
    var config: Configuration
    
    var body: some View{
        Button(action: {
            self.fetcher.fetchWorkout(config.getWorkoutType(), config.week)
        }) {
            Text("Generate")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .background(Color.yellow)
                .cornerRadius(40)
                .foregroundColor(.black)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.yellow, lineWidth: 5)
                )
                
        }
        .padding(10)
    }
}

public class WorkoutFetcher: ObservableObject {
    
    typealias ExerciseList = [Exercise]
    @Published var workoutSchedule = ExerciseList()
    @Published var isLoading = false
    let url = URL(string: "https://bro-science-prod.herokuapp.com/generate")!
    
    func fetchWorkout(_ workout: String, _ week: String) {
        let workoutParameters = GeneratorParameters(workout: workout, week: week)
        guard let request = createRequest(using: workoutParameters, at: url) else {return}
        setWorkout(using: request)
    }
    
    func fetchExercise(_ exerciseID: String, _ workout: String, _ week: String) {
        let workoutParameters = GeneratorParameters(workout: workout, week: week)
        guard let request = createRequest(using: workoutParameters, at: url) else {return}
        setWorkout(using: request, onlyExerciseID: exerciseID)
    }
    
    func createRequest(using parameters:GeneratorParameters, at url: URL) -> URLRequest? {
        let encoder = JSONEncoder()
        guard let uploadData = try? encoder.encode(parameters) else {return nil}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData
        return request
    }
    
    func setWorkout(using request: URLRequest, onlyExerciseID eid: String? = nil) {
        // insert json data to the request
        let session = URLSession.shared
        self.isLoading = true
        let task = session.dataTask(with: request) { (data, response, error) in
            if let d = data {
                let decoder = JSONDecoder()
                do {
                    let decodedLists = try decoder.decode(ExerciseList.self, from: d)
                    DispatchQueue.main.async {
                        if eid != nil {
                            let replacementExercise = decodedLists.first{$0.id==eid}
                            if let re = replacementExercise {
                                self.workoutSchedule = self.workoutSchedule.map{$0.id==eid ? re: $0}
                            }
                        }
                        else {
                            self.workoutSchedule = decodedLists
                        }
                        self.isLoading = false
                    }
                }
                catch {
                    print("Unexpected error: \(error).")
                }
            } else {
                print("Uh oh, spaghetti-os")
            }
        }
        
        task.resume()
    }
    
}

struct ScheduleView: View {
    @ObservedObject var fetcher: WorkoutFetcher
    @ObservedObject var config: Configuration
    @Environment(\.managedObjectContext) var context
    @State var editExercise = false
    @State var currentExercise: Exercise? = nil


    var body: some View {
        if fetcher.isLoading {
            Text("Loading...")
                .padding(10)
        }
        else {
            List(fetcher.workoutSchedule) { exercise in
                VStack (alignment: .leading) {
                    Text(exercise.name)
                    Text(exercise.setsAndReps)
                        .font(.system(size: 11))
                }
                .onTapGesture {
                    self.editExercise = true
                    self.currentExercise = exercise
                }
            }.sheet(isPresented: $editExercise){
                ExerciseSheet(fetcher: fetcher, config: config, currentExercise: $currentExercise)
                    .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
                    .environment(\.managedObjectContext, context)
            }
        }
    }
}

struct ExerciseSheet: View {
    @ObservedObject var fetcher: WorkoutFetcher
    @ObservedObject var config: Configuration
    @Environment(\.managedObjectContext) var context
    @Binding var currentExercise: Exercise?
    @State var sets: Int = 0
    @State var reps: Int = 0
    @State var weight: Int = 0
    
    var body: some View {
        if let exercise = currentExercise {
            VStack{
                ResampleButton(fetcher: fetcher, config: config, exerciseId: exercise.id)
                Text(exercise.name).font(.title)
                HStack{
                    VStack{
                        Text("Sets")
                        Picker("Sets", selection: $sets) {
                            ForEach(0 ..< 100) {
                                Text("\($0)")
                            }
                        }.pickerStyle(WheelPickerStyle())
                        .offset(y:-100)
                    }
                    .frame(width: 100)
                    .clipped()
                    VStack{
                        Text("Reps")
                        Picker("Reps", selection: $reps) {
                            ForEach(0 ..< 100) {
                                Text("\($0)")
                            }
                        }.pickerStyle(WheelPickerStyle())
                        .offset(y:-100)
                    }
                    .frame(width: 100)
                    .clipped()
                    VStack{
                        Text("Weight")
                        Picker("Weight", selection: $weight) {
                            ForEach(0 ..< 200){
                                Text("\($0 * 5) lbs")
                            }
                        }.pickerStyle(WheelPickerStyle())
                        .offset(y:-100)
                    }
                    .frame(width: 100)
                    .clipped()
                }
                .offset(y: 50)
                SaveExerciseButton(sets: sets, reps: reps, weight: weight, exerciseId: exercise.id)
                    .environment(\.managedObjectContext, context)
            }
        }
        else {
            Text("Uh, oh Spaghetti-Os")
        }
    }
}

struct ResampleButton: View {
    var fetcher: WorkoutFetcher
    var config: Configuration
    var exerciseId: String
    @Environment(\.managedObjectContext) var context
    
    var body: some View{
        Button(action: {
            self.fetcher.fetchExercise(exerciseId, config.getWorkoutType(), config.week)
        }) {
            Text("Resample")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .background(Color.yellow)
                .cornerRadius(40)
                .foregroundColor(.black)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.yellow, lineWidth: 5)
                )
                
        }
        .padding(10)
    }
}

struct SaveExerciseButton: View {
    var sets: Int
    var reps: Int
    var weight: Int
    var exerciseId: String
    @State private var showingAlert = false
    
    var body: some View{
        Button(action: {
            self.showingAlert = true
        }) {
            Text("Save Exercsise")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .background(Color.yellow)
                .cornerRadius(40)
                .foregroundColor(.black)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.yellow, lineWidth: 5)
                )
                
        }
        //TODO:  Implement saving to Core Data
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text("Not Implemented"), dismissButton: .default(Text("OK")))
        }
        .padding(10)
    }
}

struct Exercise: Codable, Identifiable {
    public var name: String
    public var setsAndReps: String
    public var id: String
    
    enum CodingKeys: String, CodingKey {
           case name = "Exercise"
           case setsAndReps = "Sets and Reps"
           case id = "Type"
        }
     
    public var sets: Int {
        set{
            let reps = convertSetsAndReps().reps
            self.setsAndReps = "\(newValue)x\(reps)"
        }
        get {
            return convertSetsAndReps().sets
        }
    }
    
    public var reps: Int {
        set{
            let sets = convertSetsAndReps().sets
            self.setsAndReps = "\(sets)x\(newValue)"
        }
        get {
            return convertSetsAndReps().reps
        }
    }
    
    private func convertSetsAndReps() -> (sets: Int, reps: Int) {
        let split = self.setsAndReps.components(separatedBy: "x")
        let sets = Int(split.first ?? "0") ?? 0
        let reps = Int(split.last ?? "0") ?? 0
        return (sets: sets, reps: reps)
    }
        
}


struct GeneratorParameters: Codable {
    let workout: String
    let week: String
}


struct WorkoutGenerator_Previews: PreviewProvider {
    static var previews: some View {
        SaveExerciseButton(sets: 10, reps: 10, weight: 100, exerciseId: "asdf")
    }
}
