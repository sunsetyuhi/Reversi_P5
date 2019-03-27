//初期設定
void startPosition() {
  x=y=0;
  bw=1; //先手(黒石)は1、後手(白石)は-1
  move=0;
  start=true;
  
  //石の初期配置を指定
  for (int i=0;i<=9;i++){
    for (int j=0;j<=9;j++){
      if ((i==4&&j==5) || (i==5&&j==4)) {board[i][j]=1;} //黒は1
      else if ((i==4&&j==4) || (i==5&&j==5)) {board[i][j]=-1;} //白は-1
      else if (i==0||j==0||i==9||j==9) {board[i][j]=2;} //外縁は2
      //else if ((i==1&&j==1)||(i==1&&j==8)||(i==8&&j==1)||(i==8&&j==8)){board[i][j]=-1;}  //ハンデ
      else {board[i][j]=0;} //空マスは0
    }
  }
}

//盤面、両者の石、次の手番、打てる所を描画
void showBoard(){
  //盤面(背景とグリッド)を描画
  background(0,160,0);
  stroke(0);
  for (int i=1;i<=8;i++){
    line(i*side,0, i*side,height); //縦線
    line(0,i*side, 8*side,i*side); //横線
  }
  
  //石を描画し、打てる所にマーク
  noStroke();
  num0=numB=numW=0; //打てる所と両者の石数を数える
  for (int i=1;i<=8;i++){
    for (int j=1;j<=8;j++){
      if (board[i][j]==1){ //黒(1)
        fill(0);
        ellipse((i-1)*side +side/2, (j-1)*side +side/2, 0.9*side, 0.9*side);
        numB++;
      }
      else if (board[i][j]==-1){ //白(-1)
        fill(255);
        ellipse((i-1)*side +side/2, (j-1)*side +side/2, 0.9*side, 0.9*side);
        numW++;
      }
      else if (validMove(i,j)){ //打てる所にマーク
        if(bw==-1){fill(255, 255, 255, 200);}
        else if(bw==1){fill(0, 0, 0, 200);}
        ellipse((i-1)*side +side/2, (j-1)*side +side/2, side/3, side/3);
        num0++;
        pass=0; //パスの回数を元に戻す
      }
    }
  }
	
  //COMの手
  if(turn!=-1){
    fill(255, 0, 0, 127);  noStroke();
    rect((x-1)*side,(y-1)*side, side,side);
  }
  
  //手番を表示(右上)
  textSize(side/2);
  textAlign(CENTER);
  fill(255,0,0);
  text("TURN", 9*side,side/2);
  stroke(0);
  rectMode(CENTER);
  noFill();
  rect(9*side,side, side,side); //外枠
  noStroke();
  if (bw==1) {fill(0);} //黒番
  else {fill(255);} //白番
  ellipse(9*side,side, side,side);
  
  //戻るボタン(右中)
  rectMode(CORNER);
  fill(255,255,0);
  rect(8.3*side,3.5*side, 1.4*side,0.7*side); //外枠
  textSize(side/2.5);
  textAlign(CENTER);
  fill(0);
  text("BACK", 9*side,height/2);
  
  //両者の石の数(右下)
  textSize(side*0.35);
  textAlign(CENTER);
  fill(0);
  text("BLACK:"+numB, 9*side,height-side);
  fill(255);
  text("WHITE:"+numW, 9*side,height-side/2);
}
