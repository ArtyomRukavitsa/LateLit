//
//  Message.swift
//  LateLit
//
//  Created by Daniel Khromov on 2/11/20.
//  Copyright © 2020 Daniel Khromov. All rights reserved.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
struct Message: View {
    var subjects = ["ООП", "Алгебра", "Биология", "География", "Английский", "ТОИ", "История", "Литература", "Обществознание", "Русский", "Технология", "Физика", "Физ-ра", "Химия"]
    @State private var selectedSubject = 0
    @State var subjectToSend = " "
    @State var numOfSubjectToSend = 0
    @State private var numOfSub = 0
    @State private var reason = ""
    @State private var name = " "
    @State private var surname = " "
    @State private var showingAlert = false
    @State private var showingAlertAgain = true
    @Binding var showMessageView: Bool
    let ref = Database.database().reference(withPath: "Users")
    let lateList = Database.database().reference(withPath: "late_list")
    var body: some View {
        
        NavigationView{
            ScrollView {
        VStack{
            Text("Отправка сообщения")
                .font(.body)
                .bold()
           
            Picker(selection: $selectedSubject, label: Text("Предмет")){
                ForEach(0 ..< subjects.count){ index in
                    Text(self.subjects[index]).tag(index).contrast(5)
                    
                }
            }
            
            
                Picker(selection: $numOfSub, label: Text("Номер урока")){
                ForEach(1 ..< 8){ index in
                    Text("\(index)").tag(index).contrast(5)
                }
                }
               
            
            TextField("Причина", text: $reason)
            .textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            
            Button(action: {
                self.subjectToSend = self.subjects[self.selectedSubject]
                self.numOfSubjectToSend = self.numOfSub
                let userID = Auth.auth().currentUser?.uid
                self.ref.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                    if let value = snapshot.value as? NSDictionary{
                        let nameInBase = value["name"] as? String ?? "Имя не указано"
                        let surnameInBase = value["surname"] as? String ?? "Имя не указано"
                        self.name = nameInBase
                        self.surname = surnameInBase
                    }
                    
            })
                print(self.name)
                print(self.surname)
                print(self.numOfSubjectToSend+1)
                if(self.showingAlertAgain == true){
                self.showingAlert = true
                }
                else{
                    self.showMessageView.toggle()
                }
                })
            {
                Text("Отправить")
                    .font(.body)
                    .foregroundColor(.white)
                    .background(Color("Color"))
                    .cornerRadius(5)
                    .padding()
                    .mask(Rectangle())
                       
        }
             Spacer()
        }
            .alert(isPresented: $showingAlert)
            {
                Alert(title: Text("Отправить?"), message: Text("Нажмите отправить еще раз и все проверьте"), dismissButton: .default(Text("OK")){
                    self.showingAlert = false
                    self.showingAlertAgain = false
                    //format date
                    let currentDate = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd_M_yyyy"
                    let timeToString = formatter.string(from: currentDate)
                    let timestamp = Date().currentTimeMillis()
                    print(timestamp)
                    
                    self.lateList.observeSingleEvent(of: .value, with: {(snapshot) in
                        if snapshot.hasChild("\(timeToString)") {
                            self.lateList.child("\(timeToString)").child("/\(timestamp)").setValue(["lesson":"\(self.numOfSubjectToSend) \(self.subjectToSend)", "name": self.name, "reason": self.reason, "surname" : self.surname])
                        }
                        else{
                            self.lateList.child("\(timeToString)").child("/\(timestamp)").setValue(["lesson":"\(self.numOfSubjectToSend) \(self.subjectToSend)", "name": self.name, "reason": self.reason, "surname" : self.surname])
                        }
                    })
                     
                    })
            }
    }
        }
    }
}
    
    
        
struct Message_Previews: PreviewProvider {
    static var previews: some View {
        Message(showMessageView: .constant(true))
    }
}
extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
