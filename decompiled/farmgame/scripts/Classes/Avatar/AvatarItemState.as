package Classes.Avatar
{
   import Classes.util.FarmGameUtil;
   import MyLife.NPC.SimpleNPC;
   
   public class AvatarItemState
   {
      
      private var m_unlockedItems:Object = {};
      
      private var m_inventoryInitialized:Boolean = false;
      
      private var m_previousConfigurations:Object = {
         "male":{},
         "female":{}
      };
      
      public function AvatarItemState()
      {
         super();
         this.m_unlockedItems = {};
         this.m_inventoryInitialized = false;
      }
      
      public function canBuy(avatarItemId:String, ignoreGender:Boolean = false) : Boolean
      {
         var gender:String = null;
         var avatarItem:AvatarItem = Global.avatarConfigSettings.getItemById(avatarItemId);
         var limitedDateGate:Boolean = true;
         if(Boolean(avatarItem.limitedStartDate) && Boolean(avatarItem.limitedEndDate))
         {
            limitedDateGate = FarmGameUtil.isTimeWithinDateRange(avatarItem.limitedStartDate,avatarItem.limitedEndDate);
         }
         var genderGate:Boolean = true;
         if(!ignoreGender)
         {
            gender = Global.player.avatar.gender == SimpleNPC.GENDER_MALE ? AvatarConfigSettings.GENDER_MALE : AvatarConfigSettings.GENDER_FEMALE;
            if(!avatarItem.hasKeyword(gender))
            {
               genderGate = false;
            }
         }
         return avatarItem.buyable && limitedDateGate && genderGate && !this.isOwned(avatarItemId);
      }
      
      public function get inventoryInitialized() : Boolean
      {
         return this.m_inventoryInitialized;
      }
      
      public function isOwned(avatarItemId:String) : Boolean
      {
         var isOwned:Boolean = false;
         var avatarItem:AvatarItem = Global.avatarConfigSettings.getItemById(avatarItemId);
         if(avatarItem)
         {
            isOwned = avatarItem.isFree || this.isPurchased(avatarItemId);
         }
         else if(Number(avatarItemId) < 0)
         {
            isOwned = true;
         }
         return isOwned;
      }
      
      public function isPurchased(avatarItemId:String) : Boolean
      {
         var key:String = null;
         var purchased:Boolean = false;
         for(key in this.m_unlockedItems)
         {
            if(key == avatarItemId)
            {
               purchased = true;
               break;
            }
         }
         return purchased;
      }
      
      public function getRecentlyWorn(gender:String, category:String) : AvatarItem
      {
         var itemId:String = null;
         var item:AvatarItem = null;
         var config:Object = this.getAllRecentlyWorn(gender);
         if(config.hasOwnProperty(category))
         {
            itemId = config[category];
            item = Global.avatarConfigSettings.getItemById(itemId);
         }
         return item;
      }
      
      public function getAllRecentlyWorn(gender:String) : Object
      {
         var result:Object = {};
         if(this.m_previousConfigurations.hasOwnProperty(gender))
         {
            result = this.m_previousConfigurations[gender];
         }
         return result;
      }
      
      public function grantItem(avatarItemId:String) : void
      {
         var avatarItem:AvatarItem = Global.avatarConfigSettings.getItemById(avatarItemId);
         if(avatarItem)
         {
            if(!avatarItem.isFree)
            {
               this.m_unlockedItems[avatarItemId] = avatarItem;
               return;
            }
            throw new Error("AvatarState attempted to unlock free item :" + avatarItem.name + " id:" + avatarItem.itemId);
         }
         throw new Error("AvatarState attempted to unlock unknown item with id " + avatarItemId);
      }
      
      public function rememberConfigurationItem(gender:String, itemId:String) : void
      {
         var avatarItem:AvatarItem = Global.avatarConfigSettings.getItemById(itemId);
         if(Boolean(avatarItem) && Boolean(gender))
         {
            this.m_previousConfigurations[gender][avatarItem.category] = itemId;
         }
      }
      
      public function initAvatarStateFromInitUser(resultInfo:Object) : void
      {
         var unlocked:Object = null;
         var key:String = null;
         var avatarItem:AvatarItem = null;
         var genderConfigs:Object = null;
         var gender:String = null;
         if(resultInfo.hasOwnProperty("unlocked"))
         {
            unlocked = resultInfo.unlocked;
            for(key in unlocked)
            {
               avatarItem = Global.avatarConfigSettings.getItemById(key);
               if(avatarItem)
               {
                  this.m_unlockedItems[key] = avatarItem;
               }
            }
            this.m_inventoryInitialized = true;
         }
         if(resultInfo.hasOwnProperty("configurations"))
         {
            genderConfigs = resultInfo.configurations;
            for(gender in genderConfigs)
            {
               this.m_previousConfigurations[gender] = genderConfigs[gender];
            }
         }
      }
   }
}

