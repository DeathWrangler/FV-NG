package Transactions
{
   import Engine.Transactions.Transaction;
   import Managers.UnicornMusicPlayerManager;
   
   public class TRefreshMusicPlayerHudIcon extends Transaction
   {
      
      public function TRefreshMusicPlayerHudIcon()
      {
         super();
      }
      
      override public function perform() : void
      {
         UnicornMusicPlayerManager.getInstance().removeMusicPlayerHudIcon();
         signedCall("MusicPlayerService.isAuthorizedToGetMusicToken");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result)
         {
            UnicornMusicPlayerManager.getInstance().addMusicPlayerHudIcon();
         }
      }
   }
}

