package Transactions
{
   import Classes.Avatar.FarmAvatar;
   import Classes.IUser;
   import Classes.Player;
   import Display.UI;
   import Engine.Classes.SocialNetworkUser;
   
   public class TGetAvatarData extends TFarmTransaction
   {
      
      protected var m_userId:String;
      
      private var m_callBackFunc:Function;
      
      public function TGetAvatarData(userId:String, callBackFunc:Function)
      {
         super();
         this.m_userId = userId;
         this.m_callBackFunc = callBackFunc;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getAvatarData",this.m_userId.toString());
      }
      
      override protected function onComplete(result:Object) : void
      {
         var player:IUser = null;
         var snUser:SocialNetworkUser = null;
         var playerAvatar:FarmAvatar = null;
         if(result)
         {
            if(this.m_userId == Global.player.snUser.uid)
            {
               player = Global.getPlayer();
            }
            else if(this.m_userId)
            {
               player = Global.friendManager.getFriendData(this.m_userId);
            }
            if(player == null)
            {
               snUser = new SocialNetworkUser(this.m_userId);
               snUser.firstName = "";
               snUser.name = "";
               snUser.picture = "";
               if(result.firstName)
               {
                  snUser.firstName = result.firstName;
               }
               if(result.name)
               {
                  snUser.name = result.name;
               }
               if(result.picture)
               {
                  snUser.picture = result.picture;
               }
               player = new Player(snUser);
            }
            if(result.avatar)
            {
               playerAvatar = new FarmAvatar(result.avatar);
               playerAvatar.createDisplayObject();
               if(player)
               {
                  player.avatar = playerAvatar;
               }
            }
            this.m_callBackFunc(player);
         }
      }
      
      override protected function onFault(errorType:int, errorData:String) : void
      {
         UI.displayMessage("TGetAvatarData onFault");
      }
   }
}

