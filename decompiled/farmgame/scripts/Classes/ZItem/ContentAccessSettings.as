package Classes.ZItem
{
   import Classes.MarketPromotion;
   import Classes.SwapDecoration;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Display.DynamicIconQueue;
   import Display.UI;
   
   public class ContentAccessSettings
   {
      
      private static const ATTR_NAME:String = "@name";
      
      private static const ATTR_CASH:String = "@cash";
      
      private static const TAG_REWARDS:String = "rewards";
      
      private static const TAG_CHECKSWAP:String = "checkForSwap";
      
      private static const TAG_HIDEICON:String = "hideIcon";
      
      private static const TAG_DIALOG_URL:String = "dialog";
      
      private var m_name:String = null;
      
      private var m_cash:int = 0;
      
      private var m_rewards:Vector.<Object> = null;
      
      private var m_itemsToBeSwapped:Vector.<Object> = null;
      
      private var m_iconsToHide:Vector.<Object> = null;
      
      private var m_dialogUrl:String;
      
      public function ContentAccessSettings(xml:XML)
      {
         super();
         if(xml)
         {
            if(xml.hasOwnProperty(ATTR_NAME))
            {
               this.m_name = xml[ATTR_NAME];
               if(xml.hasOwnProperty(ATTR_CASH))
               {
                  this.m_cash = int(xml[ATTR_CASH]);
                  if(xml.hasOwnProperty(TAG_REWARDS))
                  {
                     this.m_rewards = UserRewardUtil.getRewardsVectorFromXml(xml[TAG_REWARDS][0]);
                  }
                  if(xml.hasOwnProperty(TAG_CHECKSWAP))
                  {
                     this.m_itemsToBeSwapped = ContentAccessSettings.getItemsToBeSwappedVectorFromXml(xml[TAG_CHECKSWAP][0]);
                  }
                  if(xml.hasOwnProperty(TAG_HIDEICON))
                  {
                     this.m_iconsToHide = ContentAccessSettings.getHudIconsToBeRemovedAfterPurchaseFromXml(xml[TAG_HIDEICON][0]);
                  }
                  if(xml.hasOwnProperty(TAG_DIALOG_URL))
                  {
                     this.m_dialogUrl = xml[TAG_DIALOG_URL].toString();
                  }
                  return;
               }
               throw new Error("Cannot construct a content access settings object.  " + this.m_name + " is missing " + ATTR_CASH + "= attribute.");
            }
            throw new Error("Cannot construct a content access settings object.  Missing " + ATTR_NAME + "= attribute.");
         }
         throw new Error("Cannot construct a content access settings object from null XML");
      }
      
      public static function getItemsToBeSwappedVectorFromXml(xml:XML) : Vector.<Object>
      {
         var itemNode:XML = null;
         var items:Vector.<Object> = new Vector.<Object>();
         var xmlRewards:XMLList = xml.descendants("item");
         for each(itemNode in xmlRewards)
         {
            items.push(FarmGameUtil.xmlNodeToAttributes(itemNode));
         }
         return items;
      }
      
      public static function getHudIconsToBeRemovedAfterPurchaseFromXml(xml:XML) : Vector.<Object>
      {
         var icon:XML = null;
         var icons:Vector.<Object> = new Vector.<Object>();
         var xmlIcons:XMLList = xml.descendants("icon");
         for each(icon in xmlIcons)
         {
            icons.push(FarmGameUtil.xmlNodeToAttributes(icon));
         }
         return icons;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get cash() : int
      {
         return this.m_cash;
      }
      
      public function get dialogURL() : String
      {
         return this.m_dialogUrl;
      }
      
      public function grantRewards() : void
      {
         if(this.m_rewards)
         {
            UserRewardUtil.grantUserRewards(this.m_rewards,true);
         }
      }
      
      public function getItemNamesToBeSwapped() : Vector.<Object>
      {
         return this.m_itemsToBeSwapped;
      }
      
      public function openMiniMarket() : void
      {
         var actionParams:Array = null;
         var earlyContentItems:MarketPromotion = Global.marketConfigSettings.getMarketPromotion(this.m_name);
         if(Boolean(earlyContentItems) && Boolean(earlyContentItems.hasOwnProperty("actionParams")) && earlyContentItems.actionParams != null)
         {
            actionParams = earlyContentItems.actionParams;
            UI.displayMiniMarketDialog(actionParams,UI.MARKET_CONTEXT_UNKNOWN,"building",null,true);
         }
      }
      
      public function handleSwapDeco() : void
      {
         var swapDeco:SwapDecoration = null;
         var item:Object = null;
         var instances:Array = null;
         if(this.m_itemsToBeSwapped)
         {
            swapDeco = null;
            for each(item in this.m_itemsToBeSwapped)
            {
               instances = Global.world.getObjectsByName(item.name as String);
               if(Boolean(instances) && Boolean(instances.length > 0) && instances[0] is SwapDecoration)
               {
                  swapDeco = instances[0] as SwapDecoration;
                  swapDeco.handleSwap(true);
               }
            }
         }
      }
      
      public function hideHudIcons() : void
      {
         var icon:Object = null;
         if(this.m_iconsToHide)
         {
            for each(icon in this.m_iconsToHide)
            {
               Global.hud.rightSideIconQueue.removeIconByName(icon.name as String);
            }
         }
      }
      
      public function showIcons() : void
      {
         var icon:Object = null;
         var iconName:String = null;
         var hudIconXml:XML = null;
         var extraData:Object = null;
         if(this.m_iconsToHide)
         {
            for each(icon in this.m_iconsToHide)
            {
               iconName = icon.name as String;
               hudIconXml = Global.farmGameSettingsManager.getIconXMLByName(iconName);
               if(hudIconXml != null)
               {
                  extraData = new Object();
                  extraData.contentAccessSettingsName = this.m_name;
                  Global.hud.rightSideIconQueue.addIcon(iconName,DynamicIconQueue.ADD_BY_PRIORITY,null,extraData,false);
               }
               else
               {
                  Global.hud.rightSideIconQueue.removeIconByName(iconName);
               }
            }
         }
      }
   }
}

