package Transactions
{
   import Classes.CMysteryBoxGameDartAutoConsumable;
   import Display.MysteryBoxBalloonDialog;
   
   public class TUseMysteryBoxDartAutoConsumable extends TWorldState
   {
      
      private var m_dialog:MysteryBoxBalloonDialog;
      
      protected var m_params:Object;
      
      private var m_balloonId:int;
      
      public function TUseMysteryBoxDartAutoConsumable(consumable:CMysteryBoxGameDartAutoConsumable, gameDialog:MysteryBoxBalloonDialog, balloonId:int, isGift:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1)
      {
         super(consumable);
         this.m_dialog = gameDialog;
         this.m_params = new Object();
         this.m_params.token = MysteryBoxBalloonDialog.getCurrentTokenName();
         this.m_params.balloonId = balloonId;
      }
      
      override public function perform() : void
      {
         signedWorldAction(TWorldState.ACTION_USE,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         this.m_dialog.onDataReturn(result);
      }
   }
}

