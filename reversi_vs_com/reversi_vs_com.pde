boolean start;  //初期画面
int board[][] = new int[10][10];  //盤面の一時記録用
int board_rec[][][] = new int[100][10][10];  //盤面の最終記録用
int bw, turn;  //石の色、手番
int bw_rec[] = new int[100];  //石の色の記録用
int move, pass, side;  //手数。パスの回数。1マスの長さ
int num0,numB,numW;  //石を打てる所の数、黒石の数、白石の数

void setup(){
  size(500, 400); //8*side +2*side, h=8*side
  //fullScreen();
  smooth();
  frameRate(2);
  side=height/8;
  
  startPosition();
  showBoard(); //盤面を描画する関数の呼び出し
  
  //初期画面
  rectMode(CORNER);
  fill(0,160,0,220);
  rect(0,0, width,height/3);
  fill(0,220);
  rect(0,height/3, width/2,height);
  fill(255,220);
  rect(width/2,height/3, width,height);
  
  textAlign(CENTER,TOP);
  textSize(side); //文字の大きさ
  fill(255, 160, 0);
  text("REVERSI P5", width/2, 0.5*side);
  textSize(side/2);
  text("'HUMAN' vs 'COMPUTER'", width/2, 1.5*side);
  
  fill(0, 160, 255);
  text("The first move\n(Black)", width/4, height/2);
  text("The second move\n (White)", width*3/4, height/2);
}

void draw(){
  com();  //コンピュータの手
  passCheck();  //パスの判定
}

void mousePressed(){
  man();  //人間の手
	
  //手番選択
  if (start==true && mouseY>=height/3){
    if (mouseX<=width/2) {turn=1;} //手番は人間から(the first move)
    if (mouseX>=width/2) {turn=-1;} //手番はAIから(the second move)
    start=false; //初期画面を消す
    showBoard(); //盤面、両者の石、次の手番、置ける所を描画
  }
	
  //戻るボタンの実行
  if (8.3*side<=mouseX && mouseX<=9.7*side){
    if (3.5*side<=mouseY && mouseY<=4.2*side){
      if(move==1){
        move=0;
        turn=-turn;
        recorder(false);
      }
      else if(2<=move){
        move--;
        while(bw!=bw_rec[move]){move--;}
        recorder(false); //前の局面に戻す
      }
      showBoard();
    }
  }
}

void man(){
  int i = floor(mouseX/side +1); //各マスの左上の座標を定義
  int j = floor(mouseY/side +1); //floor()で小数点以下切り捨て
  
  //初期画面が終わり、手番が人間(1)、クリックしたマスに石を打てる時
  float n=0;
  //String board_value[][] = new String[10][10]; //各マスの評価値
  
  if (start==false && turn==1 && i<=8 && validMove(i,j)){
    recorder(true); //石の配置を記録
    
    for (int k=1;k<=8;k++){
      for (int l=1;l<=8;l++){
        if (validMove(k,l)){ //打てる所があれば実行
          float m = posMoves(k,l) +kaihodo(k,l);
          //float m = kaihodo(k,l);
          
          movePiece(k,l); //仮に打つ
          bw = -bw; //石の色を反転
          move++;
          
          //評価関数
          if(move <= opening) { //opening手目まではバラつかせる
            n = 0.0;
            
	    //board_value[k][l] = nfs(round(n),4);
	    print(k +"-" +l +"," +nfs(round(n),4) +";   ");
          }
          else if(move <= 60-end_d) { //60-end_d手目まではmid_d手読み
            n = -negascout(mid_d-2,-score_max,score_max,0) +m -numMoves();
            
	    //board_value[k][l] = nfs(round(n),4);
	    print(k +"-" +l +"," +nfs(round(n),4) +";   ");
          }
          else { //終盤2から完全読み
            n = -negaalpha(end_d-1,-score_max,score_max,0);
            
	    //board_value[k][l] = nfs(round(n),3) +"!";
	    print(k +"-" +l +"," +nfs(round(n),3) +"!;   ");
          }
          
          move--;  recorder(false); //元の盤面に戻す
        }
        //else{board_value[k][l] = "----";};
      }
    }
    println("");
    
    //各マスの評価値を表示
    /*for (int k=1;k<=8;k++){
      for (int l=1;l<=8;l++){
        print(board_value[l][k] +",");
      }
      println("");
    }//*/
		
    float m = posMoves(i,j) +kaihodo(i,j);
		
    movePiece(i,j);
    bw = -bw; //石の色を反転
    move++;
    
    //評価関数
    if(move <= 2) { //2手目まではバラつかせる
      n = 0;
    }
    else if(move <= 60-end_d) { //
      n = -negascout(mid_d-2,-score_max,score_max,0) +m -numMoves();
    }
    else { //
      n = -negaalpha(end_d-1,-score_max,score_max,0);
    }
    
    println(">> mv"+ nf(move,2) +",MAN"+ i +"-"+ j +";  values = "+ nfs(round(n),4) +";  ");
    println("");
    turn = -turn; //手番交替
    showBoard(); //盤面を描画する関数の呼び出し
  }
}
