package Classes.consumables
{
   import Classes.Consumable;
   import Display.MysteryBoxBalloonDialog;
   import Display.UI;
   
   public class CMysteryBoxGameDart extends Consumable
   {
      
      public function CMysteryBoxGameDart(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         var tokenName:String = MysteryBoxBalloonDialog.getCurrentTokenName();
         var m_mysteryBoxBalloonDialog:MysteryBoxBalloonDialog = new MysteryBoxBalloonDialog(tokenName,this);
         UI.displayPopup(m_mysteryBoxBalloonDialog,true);
      }
   }
}

