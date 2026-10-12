package Widgets.Windows.RecipeBooth
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.RecipeBoothManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.RecipeBooth.RecipeBoothResultSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class RecipeBoothResultWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_featureName:String;
      
      private var m_result:Object;
      
      private var m_closeCallback:Function;
      
      public function RecipeBoothResultWindow(featureName:String, result:Object, closeCallback:Function)
      {
         var dialogAssetUrl:String = null;
         this.m_featureName = featureName;
         this.m_result = result;
         this.m_closeCallback = closeCallback;
         var building:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(featureName);
         var dialogConfig:Object = building.getDialogConfig("reward");
         if(Boolean(dialogConfig) && Boolean(dialogConfig["path"]))
         {
            dialogAssetUrl = dialogConfig["path"];
         }
         if(dialogAssetUrl)
         {
            super(dialogAssetUrl);
         }
         else
         {
            GlobalEngine.assert(false,"Building item xml is missing dialog config information.");
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var icon:FarmIcon = null;
         var message:String = null;
         var resultIngredients:Object = null;
         var items:Array = null;
         var gameSettings:Object = null;
         var ingredients:Array = null;
         var ingredient:Object = null;
         var ingredientItemName:String = null;
         var count:int = 0;
         var slots:RecipeBoothResultSlotContainerFrame = null;
         super.postLoadComplete();
         var itemName:String = this.m_result[RecipeBoothManager.KEY_LOOT_ITEM];
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(item)
         {
            icon = addWidget(new FarmIcon(m_window.icon_mc)) as FarmIcon;
            icon.setIconSize(ICON_SIZE,ICON_SIZE);
            icon.setSmoothing(true);
            icon.loadIcon(item.iconUrl);
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Dialogs","RecipeBoothResult_Title")));
            message = ZLocUtils.t("Dialogs","RecipeBoothResult_Message",{"item":ZLocUtils.tk_pk(item.friendlyName)});
            addWidget(new FarmTextField(m_window.item_tf,message));
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","RecipeBoothResult_Accept"),this.onAcceptButtonClick)) as FarmAnimatedTextButton;
            resultIngredients = this.m_result[RecipeBoothManager.KEY_INGREDIENTS] as Object;
            if(resultIngredients)
            {
               items = [];
               gameSettings = RecipeBoothManager.getGameSettings(this.m_featureName);
               ingredients = gameSettings[RecipeBoothManager.KEY_INGREDIENTS] as Array;
               for each(ingredient in ingredients)
               {
                  ingredientItemName = ingredient[RecipeBoothManager.KEY_ITEM_NAME] as String;
                  count = resultIngredients[ingredientItemName] as int;
                  items.push({
                     "itemName":ingredientItemName,
                     "count":count
                  });
               }
               if(items.length > 0)
               {
                  slots = addWidget(new RecipeBoothResultSlotContainerFrame(m_window.slots_mc)) as RecipeBoothResultSlotContainerFrame;
                  slots.items = items;
               }
            }
         }
      }
      
      override public function close() : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         super.close();
      }
      
      override protected function release() : void
      {
         this.m_result = null;
         this.m_closeCallback = null;
         super.release();
      }
      
      private function onAcceptButtonClick(event:MouseEvent) : void
      {
         var rewardItemName:String = null;
         var rewardLink:String = null;
         var rewardItem:FarmItem = null;
         var bundleData:Object = null;
         var lootItemName:String = this.m_result[RecipeBoothManager.KEY_LOOT_ITEM];
         var lootItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(lootItemName);
         if(lootItem)
         {
            rewardItemName = this.m_result[RecipeBoothManager.KEY_REWARD_ITEM];
            rewardLink = this.m_result[RecipeBoothManager.KEY_REWARD_LINK];
            if(Boolean(rewardItemName) && Boolean(rewardLink))
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardItemName);
               if(rewardItem)
               {
                  bundleData = {};
                  bundleData["reward_link"] = rewardLink;
                  bundleData["images"] = [{
                     "href":"{SN_APP_URL}" + rewardLink,
                     "src":rewardItem.iconUrl
                  }];
                  bundleData["lootItemName"] = lootItem.friendlyTitle;
                  bundleData["rewardItemName"] = rewardItem.friendlyTitle;
                  GlobalEngine.socialNetwork.publishFeedStory(this.m_featureName + "_MakeRecipeReward",bundleData,[],false);
               }
            }
         }
         this.close();
      }
   }
}

