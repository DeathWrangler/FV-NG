package Transactions
{
   import Classes.consumables.CMysteryBoxGameDart;
   import Display.MysteryBoxBalloonDialog;
   
   public class TUseMysteryBoxDartConsumable extends TUseConsumable
   {
      
      private var m_dialog:MysteryBoxBalloonDialog;
      
      private var m_balloonId:int;
      
      public function TUseMysteryBoxDartConsumable(consumable:CMysteryBoxGameDart, gameDialog:MysteryBoxBalloonDialog, balloonId:int, isGift:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1)
      {
         super(consumable,isGift,true,userID,isFree,storageId);
         this.m_dialog = gameDialog;
         m_params.token = MysteryBoxBalloonDialog.getCurrentTokenName();
         m_params.balloonId = balloonId;
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         this.m_dialog.onDataReturn(result);
      }
   }
}

