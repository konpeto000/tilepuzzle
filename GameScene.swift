//
//  GameScene.swift
//  tilepuzzle
//
//  Created by Kinpira on 2014/11/11.
//  Copyright (c) 2014年 Kinpira. All rights reserved.
//

import SpriteKit


let NumColumns = 6
let NumRows = 10
let TileSize:CGFloat = 50

let BoardLayerPosition = CGPointMake(20, -80)
let TextFieldPosition = CGPointMake(20, -20)

class GameScene: SKScene {
    
    var board = SKSpriteNode()
    let boardLayer = SKNode()
    let shapeLayer = SKNode()
    
    let textLayer = SKNode()
    let strLayer = SKNode()
    
    let score = SKLabelNode()
    
    var tileArrayPos = Array(count: NumColumns, repeatedValue: Array(count: NumRows, repeatedValue: CGPoint()))
    var touchedNode = SKNode()
    var moveActionFlag = false
    var scorePoint = 0
    
    override init(size:CGSize){
        super.init(size: size)
        
        backgroundColor = UIColor.grayColor()
        anchorPoint = CGPointMake(0, 1.0)
        
        addChild(boardLayer)
        addChild(textLayer)
        
        board = SKSpriteNode(color:UIColor.whiteColor(),size:CGSizeMake(CGFloat(NumColumns)*TileSize, CGFloat(NumRows)*TileSize))
        board.name = "board"
        board.anchorPoint = CGPointMake(0, 1.0)
        board.position = BoardLayerPosition
        
        let textfield = SKSpriteNode(color:UIColor.whiteColor(),size:CGSizeMake(CGFloat(NumColumns)*TileSize, 80))
        textfield.position = TextFieldPosition
        textfield.anchorPoint = CGPointMake(0, 1.0)
        
        score.fontColor = UIColor.blackColor()
        score.position = CGPointMake(textfield.position.x*10, textfield.position.y-30)
        textfield.addChild(score)
        
        strLayer.position = TextFieldPosition
        strLayer.addChild(textfield)
        textLayer.addChild(strLayer)
        
        shapeLayer.position = BoardLayerPosition
        shapeLayer.addChild(board)
        boardLayer.addChild(shapeLayer)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        initMakeTile()

    }
    
    func randomColor()->UIColor{
        //0:red,1:green,2:blue,3:yellow
        let rnd = arc4random()%4
        var color:UIColor!
        switch rnd{
        case 0:
            color = UIColor.redColor()
        case 1:
            color = UIColor.greenColor()
        case 2:
            color = UIColor.blueColor()
        case 3:
            color = UIColor.yellowColor()
        default:
            break
        }
        return color
    }
    
    func initMakeTile(){
        
        for(var i:Int = 0;i < NumColumns;i++){
            for(var j:Int = 0;j < NumRows;j++){
                let sprite = makeTileOne()

                sprite.position = CGPointMake(CGFloat(i)*TileSize,-CGFloat(j)*TileSize)
                tileArrayPos[i][j] = sprite.position
                
                board.addChild(sprite)
            }
        }
        
    }
    
    func makeTileOne()->SKSpriteNode{
        let sprite = SKSpriteNode()
        sprite.anchorPoint = CGPointMake(0, 1.0)
        sprite.alpha *= 0.8
        sprite.color = randomColor()
        sprite.size = CGSizeMake(TileSize-1, TileSize-1)
        
        return sprite
    }
    
    func moveTile(node:SKNode){
        let touchedAction = SKAction.moveTo(node.position, duration: 0.08)
        let passeagedAction = SKAction.moveTo(touchedNode.position, duration: 0.08)
        
        moveActionFlag = true
        touchedNode.runAction(touchedAction, completion: {self.moveActionFlag = false})
        node.runAction(passeagedAction, completion: {self.moveActionFlag = false})
    }
    
    func searchNode(pos:CGPoint)->SKSpriteNode{
        let node = self.nodeAtPoint(CGPointMake(pos.x+TileSize,pos.y-4*TileSize))
        return node as SKSpriteNode
    }
    
    
    func searchEmpty(node:SKSpriteNode)-> Int{
        
        var count = 0
        if(node.name != "board"){
            for(var k:Int = Int(-1*node.position.y/TileSize);k < NumRows;k++){
                let sprite = searchNode(tileArrayPos[Int(node.position.x/TileSize)][k])
                if(sprite.name == "board"){
                    count++
                }
            }
        }
        
        return count
    }
    
    func insertArray(inout arrayA:[SKNode],arrayB:[SKNode]){
        for node in arrayB{
            arrayA.append(node)
        }
    }
    
    func deleteColumns(inout array:[SKNode]){
        
        var deleteColumnsArray = Array(arrayLiteral:SKNode())
        
        for(var i:Int = 0;i < NumColumns;i++){
            var color = searchNode(tileArrayPos[i][0]).color
            var count = 0
            
            for(var j:Int = 0;j < NumRows;j++){
                var node = searchNode(tileArrayPos[i][j])
                if(color == node.color){
                    deleteColumnsArray.append(node)
                    count++

                }else{
                    if(count >= 3){
                        insertArray(&array, arrayB: deleteColumnsArray)
                    }
                    deleteColumnsArray.removeAll()
                    deleteColumnsArray.append(node)
                    color = node.color
                    count = 1
                }
                
            }
            
            if(count >= 3){
                insertArray(&array, arrayB: deleteColumnsArray)
            }
            deleteColumnsArray.removeAll()
        }
    }
    
    func deleteRows(inout array:[SKNode]){
        
        var deleteRowsArray = Array(arrayLiteral:SKNode())
        
        for(var j:Int = 0;j < NumRows;j++){
     
            var color = searchNode(tileArrayPos[0][j]).color
            var count = 0
            
            for(var i:Int = 0;i < NumColumns;i++){
                var node = searchNode(tileArrayPos[i][j])
                if(color == node.color){
                    deleteRowsArray.append(node)
                    count++
                    
                }else{
                    if(count >= 3){
                        insertArray(&array, arrayB: deleteRowsArray)
                    }
                    deleteRowsArray.removeAll()
                    deleteRowsArray.append(node)
                    color = node.color
                    count = 1
                }
                
            }
            
            if(count >= 3){
                insertArray(&array, arrayB: deleteRowsArray)
            }
            deleteRowsArray.removeAll()
        }
    }
    
    func dropTile(completion:()->()){
        
        for(var i:Int = 0;i < NumColumns;i++){
            for(var j:Int = 0;j < NumRows;j++){
                let k = searchEmpty(searchNode(tileArrayPos[i][j]))
                if(k != 0){
                    let sprite = searchNode(tileArrayPos[i][j])
                    let action = SKAction.moveTo(tileArrayPos[i][j+k], duration: 0.1)
                    sprite.runAction(action)
                }
            }
        }
        
        runAction(SKAction.waitForDuration(0.2), completion: completion)
    }
    
    func makeTileInEmpty(completion:()->()){
        
        var emptyList = Array(count:NumColumns,repeatedValue:0)
        for(var i:Int = 0;i < NumColumns;i++){
            var count = 0
            for(var j:Int = 0;j < NumRows;j++){
                if(searchNode(tileArrayPos[i][j]).name == "board"){
                    count++
                    scorePoint += 100
                }
            }
            emptyList[i] = count
        }
        var i = 0
        for k in emptyList{
            for(var j:Int = 0;j < k;j++){
                let sprite = makeTileOne()
                board.addChild(sprite)
                let action = SKAction.moveTo(tileArrayPos[i][j], duration: 0.1)
                sprite.runAction(action)
            }
            i++
        }
        runAction(SKAction.waitForDuration(0.2), completion: completion)
    }
    
    func deleteAndDropTile(){

        var deleteTileArray = Array(arrayLiteral:SKNode())
        deleteTileArray.removeAll()
        deleteColumns(&deleteTileArray)
        deleteRows(&deleteTileArray)
        
        if(deleteTileArray.isEmpty){
            return
        }
        
        board.removeChildrenInArray(deleteTileArray)
        
        dropTile(){
            self.makeTileInEmpty(){
                self.deleteAndDropTile()
            }
        }
  
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            touchedNode = self.nodeAtPoint(location)
            for node in self.board.children{
                if(touchedNode == node as NSObject){
                    touchedNode.alpha *= 0.5
                }
            }

        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let passagedNode = self.nodeAtPoint(location)
            for node in self.board.children{
                if(passagedNode == node as NSObject && touchedNode != passagedNode && !moveActionFlag){
                    moveTile(passagedNode)
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let endedNode = self.nodeAtPoint(location)
            for node in self.board.children{
                if(endedNode == node as NSObject && !moveActionFlag){
                    deleteAndDropTile()
                    touchedNode.alpha *= 2
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        score.text = "Score : \(scorePoint)"
    }
}
