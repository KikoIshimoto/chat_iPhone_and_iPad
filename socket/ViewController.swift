//
//  ViewController.swift
//  socket
//
//  Created by IshimotoKiko on 2017/07/20.
//  Copyright © 2017年 IshimotoKiko. All rights reserved.
//

import UIKit
import SocketIO
import JSQMessagesViewController

//メッセージのやり取りをするユーザーを定めるclass作成
struct User {
    let id: String
    var name: String
}

class ViewController: JSQMessagesViewController {
    //user1が使用者側、user2が相手側
    
    var roomID:String? = ""
    var name:String? = ""
    
    var IPAddress:String? = ""
    var SocketURL:NSURL!;
    var socket: SocketIOClient!
    
    var users:[String:User] = [:]
    
    let server = User(id: "0", name: "server")
    var user1 =  User(id: "1", name: "iPhone")
    let user2 =  User(id: "2", name: "Android")
    
    
    var currentUser: User {
        return user1
    }
    var serverUser: User {
        return server
    }
    
    var messages = [JSQMessage]()
}

extension ViewController {
    //送信ボタンが押された時の挙動
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        //let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        //messages.append(message!)
        
        let post : Dictionary<String, String> = ["room":roomID!, "id":senderId, "text":text,"name":senderDisplayName]
        self.socket.emit("post", post);
        print("push end")

        //finishSendingMessage()
    }
    
    //添付ファイルボタンが押された時の挙動
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
    }
    
    //各送信者の表示について
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUsername = message.senderDisplayName
        
        return NSAttributedString(string: messageUsername!)
    }
    
    //各メッセージの高さ
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    //各送信者の表示に画像を使うか
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    //各メッセージの背景を設定
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = messages[indexPath.row]
        if currentUser.id == message.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .green)
        } else if message.senderId == serverUser.id{
            return  bubbleFactory?.outgoingMessagesBubbleImage(with: .gray)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .blue)
        }
    }
    
    //   メッセージの総数を取得
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    //   メッセージの内容参照場所の設定
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
}

extension ViewController {
    //   画面を開いた直後の挙動。ここで使用者側の設定を行ない、過去のメッセージを取得している
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketURL = NSURL(string: IPAddress!)
        user1.name = self.name!
        socket = SocketIOClient(socketURL: SocketURL as URL)
        //socket = SocketIOClient(socketURL: SocketURL, config: nil)
        socket.on("connect") { data in
            print("socket connected!!")
            
            //let post : Dictionary<String, String> = [ "room":"abc", "name":self.user1.name , "userid":self.user1.id]
            let post : Dictionary<String, String> = [ "room":self.roomID!, "name":self.name!]
            self.socket.emit("join", post);
            print(post)
            //print("push end")
            
            
        
        }
        socket.on("disconnect") { data in
            print("socket disconnected!!")
        }
        
        socket.on("Message") { (data, emitter) in
            print("Message")
            if let message = data as? [String] {
                print(message[0])
                
                let jsonData: NSData = message[0].data(using: String.Encoding.utf8)! as NSData
                
                do {
                    let list:NSDictionary = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary

                    var dict = list as! Dictionary<String, Any>
                    print( dict["name"] as! String)
                    if((dict["id"] as? String) == nil){dict["id"] = "0"}
                    else if (dict["name"] as? String) != self.name && (dict["name"] as? String) != "SERVER"{dict["id"] = "2"}
                    print(dict["text"] as! String)
                    print(dict["id"] as? String)
                    let message1 = JSQMessage(senderId: dict["id"] as! String , displayName: dict["name"] as! String, text: dict["text"] as! String)
                    
                    self.messages.append(message1!)
                    self.finishSendingMessage()
                    
                } catch _ as NSError {
                }
            }
        }
        socket.on("joinMessage") { (data, emitter) in
            print("joinMessage")
            if let message = data as? [String] {
                print(message[0])
                let jsonData: NSData = message[0].data(using: String.Encoding.utf8)! as NSData
                
                do {
                    let list:NSDictionary = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    let dict = list as! Dictionary<String, Any>
                    print(dict["text"] as! String)
                    print((dict["id"] as! Int).description)
                    print(dict["name"] as! String)
                    let message1 = JSQMessage(senderId: (dict["id"] as! Int).description, displayName: dict["name"] as! String, text: dict["text"] as! String)
                    
                    self.messages.append(message1!)
                    self.finishSendingMessage()
                    
                } catch _ as NSError {
                }
            }
            print(self.users)
        }
        socket.connect()
        
        self.senderId = currentUser.id
        self.senderDisplayName = currentUser.name
        
    }
}

/*
import UIKit
import SocketIO

class ViewController: UIViewController, UITableViewDelegate , UITableViewDataSource{
    var SocketURL:NSURL!;
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var postTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var socket: SocketIOClient!
    var postArray: NSMutableArray!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketURL = NSURL(string: "http://192.168.0.7:8080")
        postArray = NSMutableArray()
        print(SocketURL)
        socket = SocketIOClient(socketURL: SocketURL as URL)
        //socket = SocketIOClient(socketURL: SocketURL, config: nil)
        socket.on("connect") { data in
            print("socket connected!!")
        }
        socket.on("disconnect") { data in
            print("socket disconnected!!")
        }
        
        socket.on("addedPost") { (data, emitter) in
            print("add post")
            if let message = data as? [String] {
                print(message[0])
                let jsonData: NSData = message[0].data(using: String.Encoding.utf8)! as NSData
                var err:NSError?
                do {
                    self.postArray = try JSONSerialization.jsonObject(
                        with: jsonData as Data, options:[]) as? NSMutableArray
                } catch let error as NSError {
                    err = error
                    self.postArray = nil
                    //print(err as Any)
                }
                self.tableView.reloadData()
            }
        }
        socket.connect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    
    @IBAction func pushPostButton(sender: AnyObject) {
        let post : Dictionary<String, String> = [ "name":self.nameTextField.text!, "text":self.postTextField.text!]
        print(post)
        self.socket.emit("post", post);
        print("push end")
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArray.count
    }
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("in");
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clear
        
        let data : Dictionary<String, String> = self.postArray.object(at: indexPath.row) as! Dictionary<String, String>
        print(data)
        print("cell call")
        cell.textLabel?.text = data["text"]
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        cell.detailTextLabel?.text = data["name"]
        print("cell end")
        return cell
    }
    
    @objc func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
*/
