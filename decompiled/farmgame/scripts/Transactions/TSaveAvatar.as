package Transactions
{
   import Classes.Player;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import MyLife.NPC.SimpleNPC;
   
   public class TSaveAvatar extends TFarmTransaction
   {
      
      private var m_params:Object;
      
      private var m_gender:String = "";
      
      private var m_player:Player;
      
      public function TSaveAvatar(player:Player)
      {
         super();
         this.m_player = player;
         if(this.m_player != null && this.m_player.avatar != null && this.m_player.avatar.getCharacter() != null)
         {
            this.m_params = this.m_player.avatar.getAvatarCustomizationData();
            this.m_gender = this.m_player.avatar.gender == SimpleNPC.GENDER_MALE ? "male" : "female";
            this.rememberRecentlySavedConfig(this.m_gender,this.m_params);
            FarmStatsManager.count("avatar","save_player");
         }
         else
         {
            canPerform = false;
            ErrorManager.addError("player avatar is null");
         }
      }
      
      private function rememberRecentlySavedConfig(gender:String, params:Object) : void
      {
         var category:String = null;
         var description:Object = null;
         var itemId:String = null;
         for(category in params)
         {
            description = params[category];
            itemId = description.itemId;
            Global.player.avatarState.rememberConfigurationItem(gender,itemId);
         }
      }
      
      override public function perform() : void
      {
         signedCall("AvatarService.saveAvatar",this.m_params,this.m_gender);
      }
   }
}

