int[][] board = new int[10][10];  //盤面の記録用
int bw;  //石の色。先手(黒石)は1、後手(白石)は-1
int pass,side;  //パスの回数、1マスの長さ
int num0,numB,numW;  //石を打てる所の数、黒石の数、白石の数

void setup(){
  size(400, 400); //8*side +2*side, h=8*side
  side=height/8;
  
  startPosition();  //初期設定
  showBoard();  //盤面を描画
}

void draw(){
  passCheck();  //パスの判定（終局判定もする）
}

void mousePressed(){
  int i = floor(mouseX/side +1);  //各マスの左上の座標を定義
  int j = floor(mouseY/side +1);  //floor()で小数点以下切り捨て
  
  //クリックしたマスに石を打てる時
  if (validMove(i,j)){
    movePiece(i,j);
    bw = -bw;  //石の色を反転
    showBoard();  //盤面を描画する関数の呼び出し
  }
}

void keyPressed() {
  if (key=='r') {
    startPosition();
    showBoard();
  }
}

//初期設定
void startPosition() {
  bw=1;  //先手(黒石)は1、後手(白石)は-1
  
  //石の初期配置を指定
  for (int i=0;i<=9;i++){
    for (int j=0;j<=9;j++){
      if ((i==4&&j==5) || (i==5&&j==4)) {board[i][j]=1;}  //黒は1
      else if ((i==4&&j==4) || (i==5&&j==5)) {board[i][j]=-1;}  //白は-1
      else if (i==0||j==0||i==9||j==9) {board[i][j]=2;}  //外縁は2
      else {board[i][j]=0;}  //空マスは0
    }
  }
}

//盤面、両者の石を描画
void showBoard(){
  //盤面(背景とグリッド)
  background(0,160,0);
  stroke(0);
  for (int i=1;i<=8;i++){
    line(i*side,0, i*side,height);  //縦線
    line(0,i*side, 8*side,i*side);  //横線
  }
  
  //石を描画、合法手にマーク
  noStroke();
  num0=numB=numW=0;  //打てる所と両者の石数を数える
  for (int i=1;i<=8;i++){
    for (int j=1;j<=8;j++){
      if (board[i][j]==1){  //黒(1)
        fill(0);
        ellipse((i-1)*side +side/2, (j-1)*side +side/2, 0.9*side, 0.9*side);
        numB++;
      }
      else if (board[i][j]==-1){  //白(-1)
        fill(255);
        ellipse((i-1)*side +side/2, (j-1)*side +side/2, 0.9*side, 0.9*side);
        numW++;
      }
      else if (validMove(i,j)){  //合法手
        pass=0;  //パスの回数を元に戻す
        num0++;  //合法手数を数える
        
        if(bw==-1){fill(255, 255, 255, 200);}
        else if(bw==1){fill(0, 0, 0, 200);}
        ellipse((i-1)*side +side/2, (j-1)*side +side/2, side/3, side/3);
      }
    }
  }
}

//マスの周囲8方向を調べ、石を打てるか判定
boolean validMove(int i, int j){
  if(i<1||8<i || j<1||8<j){return false;}  //盤外には打てない
  if (board[i][j]!=0) {return false;}  //空マスでなければ打てない
  
  //注目するマスの周囲8方向に対し、石を打てるか調べる
  int ri, rj;  //調べるマスを移動させるのに使う変数
  for (int di=-1; di<=1; di++){  //横方向
    for (int dj=-1; dj<=1; dj++){  //縦方向
      ri=i+di;  rj=j+dj;  //調べるマスの初期値
      
      //調べるマスが「盤の中」かつ「相手の石」ならループ
      while (board[ri][rj]!=2 && board[ri][rj]==-bw){
        ri+=di;  rj+=dj;  //次のマスに移動
        
        //同色の石に出会った(打てると分かった)時
        if (board[ri][rj]==bw){
          board[i][j]=0;  //仮に打った石を取る
          return true;  //打てると判定
        }
      }
    }
  }
  
  return false;  //打てないと判定
}

//石を打ち、マスの周囲8方向の返せる石を反転
void movePiece(int i, int j){
  board[i][j] = bw;  //石を打つ
  
  int ri, rj; //調べるマスを移動させるのに使う変数
  for (int di=-1; di<=1; di++){  //横方向
    for (int dj=-1; dj<=1; dj++){  //縦方向
      ri=i+di;  rj=j+dj;  //調べるマスの初期値を与える
      
      //調べるマスが「盤の中」かつ「相手の石」ならループ
      while (board[ri][rj]!=2 && board[ri][rj]==-bw){
        ri+=di;  rj+=dj;  //次のマスに移動
        
        //同色の石に出会った時、打った石まで戻りつつ間の石を反転
        if (board[ri][rj]==bw){
          ri-=di; rj-=dj;  //1マス戻る
          
          while (!(i==ri&&j==rj)){ //元のマスに戻るまで
            board[ri][rj] = bw;  //自分の石にする(石を返す)
            ri-=di; rj-=dj;  //また1マス戻る
          }
        }
      }
    }
  }
}

//パスの判定
void passCheck(){
  //打てる所が無ければ自動でパス
  if (num0==0 && pass<=1){
    pass++;  //パスの回数を数える
    bw = -bw;  //石の色を反転
    showBoard();  //盤面、両者の石、次の手番が置ける所を描画
  }
  
  //2回パスしたら勝敗を判定
  if (pass==2){
    fill(255,0,0);
    textSize(1.0*side);  //文字の大きさ
    textAlign(CENTER);
		
    if (numW<numB){text("Black win", width/2,height/2);}  //黒が多い時
    else if (numB<numW){text("White win", width/2,height/2);}  //白が多い時
    else {text("Draw", width/2,height/2);}  //引き分け
  }
}
