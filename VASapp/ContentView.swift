//
//  ContentView.swift
//  VASapp
//
//  Created by Yoshiyuki Kitaguchi on 2022/03/26.
//

import SwiftUI


class UserProfile: ObservableObject {
    /// ユーザ名
    @Published var scale: Double {
        didSet {
            UserDefaults.standard.set(scale, forKey: "scale")
        }
    }
    
    /// 初期化処理
    init() {
        scale = UserDefaults.standard.object(forKey: "scale") as? Double ?? 200
    }
}


struct TitleView: View{
    @ObservedObject var profile = UserProfile()
    @State private var goContentView: Bool = false
    @State private var goReadmeView: Bool = false
    
    var body: some View {
        VStack(spacing:0) {
            HStack{
                Text("VAS app")
                     .font(.largeTitle)
                     .padding(.bottom)
                 
                Image("VAS")
                     .resizable()
                     .scaledToFit()
                     .frame(width: 200)
            }
//            Button("Start"){
//                self.goContentView.toggle()
//            }
//            .sheet(isPresented: $goContentView) {
//                ContentView(profile: profile)
//            }
            Button(action: {
                self.goContentView = true /*またはself.show.toggle() */
            }) {
                HStack{
                    Image(systemName: "hand.point.right")
                    Text("Start")
                }
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
            .sheet(isPresented: self.$goContentView) {
                ContentView(profile: profile)
            }
            
            Button(action: {
                self.goReadmeView = true /*またはself.show.toggle() */
            }) {
                HStack{
                    Image(systemName: "book")
                    Text("Readme")
                }
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
            .sheet(isPresented: self.$goReadmeView) {
                ReadmeView(profile: profile)
            }
        }
    
    }
}



struct ContentView: View {
    @ObservedObject var profile = UserProfile()

    @State private var currentValue: Double = 5
    @State private var goCalibration: Bool = false  //送信ボタン
    @State private var showScore: Bool = false //スコア表示

    var body: some View {
        GeometryReader{geometry in
            VStack{
                Text("症状に合うところまでスライダーを動かして下さい")
                    .font(.largeTitle)
                    .position(x:geometry.size.width/2, y: geometry.size.height/7)
                    .lineLimit(3)
                
//                Text("VAS score：\(currentValue, specifier: "%.1f")")
//                    .font(.title)
                
                Slider(value: $currentValue,
                       in: 0...10,
                       label: { EmptyView() }           // iOSでは未使用
                )
                .frame(width:CGFloat(profile.scale), height:CGFloat(profile.scale)/5)
                
                ZStack{
                    VStack{
                        Image("satisfied")
                             .resizable()
                             .scaledToFit()
                        Text("(症状なし）")
                             .font(.title)
                        }
                        .frame(height: CGFloat(profile.scale/5))
                        .position(x:(geometry.size.width-profile.scale)/2)
                    VStack{
                        Image("neutral")
                            .resizable()
                            .scaledToFit()
                        Text(" ")
                             .font(.title)
                        }
                        .frame(height: CGFloat(profile.scale/5))
                        .position(x:geometry.size.width/2)
                    
                    VStack{
                        Image("unsatisfied")
                             .resizable()
                             .scaledToFit()
                        Text("(最悪の状態）")
                             .font(.title)
                        }
                        .frame(height: CGFloat(profile.scale/5))
                        .position(x:(geometry.size.width+profile.scale)/2)
                }
                
                
                HStack{
                    Button(action: {
                        self.goCalibration = true /*またはself.show.toggle() */
                    }) {
                        HStack{
                            Image(systemName: "lines.measurement.horizontal")
                            Text("Calibration")
                        }
                            .foregroundColor(Color.white)
                            .font(Font.title)
                    }
                    .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                        .background(Color.black)
                        .padding()
                    .sheet(isPresented: self.$goCalibration) {
                        CalibrationView(profile: profile)
                        //こう書いておかないとmissing as ancestorエラーが時々でる
                    }
                    
                    Button(action: {
                        self.showScore = true
                        /*またはself.show.toggle() */
                    }) {
                        HStack{
                            Image(systemName: "calendar.circle")
                            Text("Show score")
                        }
                            .foregroundColor(Color.white)
                            .font(Font.title)
                    }
                        .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                        .background(Color.black)
                        .padding()
                        .alert(isPresented: $showScore) {Alert(title: Text("VAS score：\(currentValue, specifier: "%.1f")"))}
                }
                
                
                
//                HStack{
//                    Button("Calibration") {
//                        self.goCalibration.toggle()
//                    }
//                    .sheet(isPresented: $goCalibration) {
//                        CalibrationView(profile: profile)
//                    }
//
//                    Button("Show score"){
//                        self.showScore = true
//                    }
//                    .alert(isPresented: $showScore) {
//                        Alert(title: Text("VAS score：\(currentValue, specifier: "%.1f")"))
//                    }
//                }
            }
            .frame(width: geometry.size.width)
        }
    }
}


struct CalibrationView: View {
    @ObservedObject var profile = UserProfile()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var currentValue: Double = 5
    @State private var goCalibration: Bool = false  //送信ボタン
    @State private var scaleWidth: CGFloat = 200

    var body: some View {
        GeometryReader{geometry in
            VStack{
                Text("バーが10cmになるように調節して下さい")
                    .position(x: geometry.size.width/2, y: geometry.size.height/5)
                    .font(Font.largeTitle)
                Rectangle()
                    .frame(width: CGFloat(profile.scale), height:50)
                
                Slider(value: $profile.scale,
                       in: 0...geometry.size.width
                ).frame(width:geometry.size.width)
                
                Spacer()
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                    self.goCalibration.toggle()
                }) {
                    HStack{
                        Image(systemName: "arrowshape.turn.up.backward")
                        Text("Back")
                    }
                        .foregroundColor(Color.white)
                        .font(Font.title)
                }
                    .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                    .background(Color.gray)
                    .padding()
            }
        }
    }
}

 
struct ReadmeView: View {
    @ObservedObject var profile = UserProfile()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var backtoTitle: Bool = false  //送信ボタン

    var body: some View {
        GeometryReader{geometry in
            ScrollView{
            
                VStack{
                    Text("本アプリの特徴")
                        .font(Font.largeTitle)
                        .underline(true, color: .red)
                    Text("紙を使わずにvisual analoge scale(VAS)を評価できるツールです。")
                        .font(Font.body)
                        .frame(width: geometry.size.width*2/3, height: 60,  alignment: .leading)
                    
                    Text("Calibration機能により、指標の長さを10cmに統一できます。")
                        .font(Font.body)
                        .frame(width: geometry.size.width*2/3, height: 60, alignment: .leading)
                    Text("Calibrationの結果は、次回起動時にも保存されます。")
                        .font(Font.body)
                        .frame(width: geometry.size.width*2/3, height: 60, alignment: .leading)
                   
                        
                        
                    
                    
                    
                    Spacer()
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        self.backtoTitle.toggle()
                    }) {
                        HStack{
                            Image(systemName: "arrowshape.turn.up.backward")
                            Text("戻る")
                        }
                            .foregroundColor(Color.white)
                            .font(Font.title)
                    }
                        .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                        .background(Color.black)
                        .padding()
                }
            }
        }
    }
}
