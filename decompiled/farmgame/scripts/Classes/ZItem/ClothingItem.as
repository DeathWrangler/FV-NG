package Classes.ZItem
{
   import Classes.Avatar.AvatarManager;
   import DataSources.BaseDataSource;
   import Managers.FarmStatsManager;
   
   public class ClothingItem extends FarmItem
   {
      
      public function ClothingItem(itemXML:XML, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         AvatarManager.buyAvatarItem(code,true);
         Global.player.avatar.equipItem(Global.avatarConfigSettings.getItemById(code));
         FarmStatsManager.count("Avatar","market_avatar","click_buy");
         return true;
      }
      
      override public function get sellPrice() : Number
      {
         return 0;
      }
      
      override public function get buyable() : Boolean
      {
         return Global.player.avatarState.canBuy(this.code,true);
      }
   }
}

