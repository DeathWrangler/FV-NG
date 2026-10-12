package Widgets.Frames.Crafting
{
   import Classes.Friend;
   import Classes.Player;
   import Classes.crafting.CraftingCrewMember;
   import Classes.crafting.CraftingState;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.Crafting.CraftingConstants;
   import Transactions.TGetAddCraftingCrewReward;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.CraftshopFriendSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Crafting.CraftshopWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class CraftshopFriendFrame extends FarmSlotContainerFrame
   {
      
      private static const MAX_SLOTS:int = 7;
      
      private static const CRAFTING_ADD_CREW_FEATURE_FREQUENCY:String = "CraftingAddCrewFeatureFrequency";
      
      private static const CRAFTING_ADD_CREW_TIMESTAMP:String = "CraftingAddCrewTimestamp";
      
      protected var m_window:CraftshopWindow = null;
      
      private var m_crewCountText:ZwTextField = null;
      
      private var m_addCrewBtn:FarmAnimatedTextButton = null;
      
      public function CraftshopFriendFrame(element:DisplayObject, window:CraftshopWindow)
      {
         this.m_window = window;
         super(element);
         addWidget(new ZwTextField(this.element.title_tf,ZLocUtils.t("Dialogs","CraftshopFriendFrame_title")));
         addWidget(new ZwTextField(this.element.subTitle_tf,ZLocUtils.t("Dialogs","CraftshopFriendFrame_subTitle")));
         this.m_addCrewBtn = addWidget(new FarmAnimatedTextButton(this.element.addFriends_bt,ZLocUtils.t("Dialogs","CraftshopFriendFrame_addFriends_btn"),this.onAddCrewButton)) as FarmAnimatedTextButton;
         this.m_addCrewBtn.visible = true;
         if(!this.isAddCrewActionAvailable())
         {
            this.disableAddCrewBtn();
         }
      }
      
      private function getSecondsUntilCrewActionAvailable() : int
      {
         var featureFrequencyTime:Number = Global.farmGameSettingsManager.getInt(CRAFTING_ADD_CREW_FEATURE_FREQUENCY,14400);
         var featureLastShown:Number = Global.player.getFeatureLastShown(CRAFTING_ADD_CREW_TIMESTAMP);
         var currentTime:Number = GlobalEngine.serverTime / 1000;
         return int(featureLastShown + featureFrequencyTime - currentTime);
      }
      
      private function isAddCrewActionAvailable() : Boolean
      {
         return this.getSecondsUntilCrewActionAvailable() <= 0;
      }
      
      public function disableAddCrewBtn() : void
      {
         this.m_addCrewBtn.applyGrayOut = true;
         this.refreshAddCrewTooltip();
      }
      
      public function onAddCrewButton(event:MouseEvent) : void
      {
         this.m_window.showExpandFrame(false);
         this.disableAddCrewBtn();
         if(this.isAddCrewActionAvailable())
         {
            TransactionManager.addTransaction(new TGetAddCraftingCrewReward(CraftingConstants.CRAFTSHOP_SKILL,this.onTAddCraftingCrewResponse),true);
         }
      }
      
      public function onTAddCraftingCrewResponse(result:Object) : void
      {
         var feedBundle:String = null;
         var rewardIcon:String = null;
         var bundleData:Object = null;
         if(result != null && result.rewardUrl != null && result.rewardUrl != "")
         {
            Global.player.setFeatureLastShown(CRAFTING_ADD_CREW_TIMESTAMP,GlobalEngine.serverTime / 1000,false);
            this.refreshAddCrewTooltip();
            feedBundle = Global.craftConfigSettings.getAddCrewFeedBundle(result.craftType);
            rewardIcon = Global.getAssetURL(Global.craftConfigSettings.getAddCrewFeedIcon(result.craftType));
            bundleData = {
               "reward_link":result.rewardUrl,
               "images":[{
                  "href":"{SN_APP_URL}" + result.rewardUrl,
                  "src":rewardIcon
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory(feedBundle,bundleData,[],false);
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CraftshopFriendSlot(slotElement);
      }
      
      override public function refresh() : void
      {
         this.refreshCrewList();
         this.refreshAddCrewTooltip();
         super.refresh();
      }
      
      override protected function setupData() : void
      {
         this.refreshCrewList();
         this.refreshAddCrewTooltip();
      }
      
      private function refreshAddCrewTooltip() : void
      {
         var timeRemaining:int = 0;
         var hoursRemaining:int = 0;
         var minutesRemaining:int = 0;
         var secondsRemaining:int = 0;
         var crewAvailableTimeString:String = null;
         var toolTipText:String = null;
         if(!this.isAddCrewActionAvailable())
         {
            timeRemaining = this.getSecondsUntilCrewActionAvailable();
            hoursRemaining = int(timeRemaining / 3600);
            minutesRemaining = int(timeRemaining / 60 % 60);
            secondsRemaining = int(timeRemaining % 60);
            crewAvailableTimeString = "";
            if(timeRemaining > 3600)
            {
               crewAvailableTimeString = ZLocUtils.t("Crafting","CraftingMain_ComeBackHoursMins",{
                  "hourNum":hoursRemaining,
                  "minuteNum":minutesRemaining
               });
            }
            else if(timeRemaining > 60)
            {
               crewAvailableTimeString = ZLocUtils.t("Crafting","CraftingMain_ComeBackMinsSecs",{
                  "minuteNum":minutesRemaining,
                  "secondNum":secondsRemaining
               });
            }
            else
            {
               crewAvailableTimeString = ZLocUtils.t("Crafting","General_FriendlyTimeSecs",{"secondNum":secondsRemaining});
            }
            if(this.m_addCrewBtn)
            {
               toolTipText = crewAvailableTimeString;
               if(this.m_addCrewBtn.tooltip)
               {
                  (this.m_addCrewBtn.tooltip as FarmTextTooltip).setText(toolTipText);
               }
               else
               {
                  this.m_addCrewBtn.attachTooltip(new FarmTextTooltip(toolTipText));
               }
            }
         }
      }
      
      private function refreshCrewList() : void
      {
         var crewMember:CraftingCrewMember = null;
         var friendObj:Friend = null;
         var formattedFriendName:String = null;
         var picture:String = null;
         m_slotData = new Array();
         var craftingCrew:Array = Global.player.craftingState.craftingCrew;
         var numCrewAdded:int = 0;
         var crewIndex:int = 0;
         while(crewIndex < craftingCrew.length && numCrewAdded < MAX_SLOTS)
         {
            crewMember = craftingCrew[crewIndex] as CraftingCrewMember;
            if(crewMember.m_recipeId == CraftingCrewMember.INVALID_RECIPE_ID)
            {
               friendObj = Global.friendManager.getAppFriendData(crewMember.m_uid);
               if(friendObj)
               {
                  numCrewAdded++;
                  formattedFriendName = "";
                  picture = Player.NO_PROFILE_PIC_URL;
                  if(numCrewAdded <= CraftingState.NUM_CREW_REQUIRED_TO_HELP)
                  {
                     formattedFriendName = friendObj.firstName;
                  }
                  if(friendObj.snUser != null && friendObj.snUser.picture != null)
                  {
                     picture = friendObj.snUser.picture;
                  }
                  m_slotData.push({
                     "name":formattedFriendName,
                     "icon":picture
                  });
               }
            }
            crewIndex++;
         }
         for(var emptyIndex:int = numCrewAdded; emptyIndex < MAX_SLOTS; emptyIndex++)
         {
            m_slotData.push({"icon":Player.NO_PROFILE_PIC_URL});
         }
         this.refreshCrewCountText();
      }
      
      private function refreshCrewCountText() : void
      {
         var crewMember:CraftingCrewMember = null;
         if(this.m_crewCountText == null)
         {
            this.m_crewCountText = addWidget(new ZwTextField(this.element.friendCount_tf)) as ZwTextField;
         }
         var craftingCrew:Array = Global.player.craftingState.craftingCrew;
         var crewCount:int = 0;
         for(var crewIndex:int = 0; crewIndex < craftingCrew.length; crewIndex++)
         {
            crewMember = craftingCrew[crewIndex] as CraftingCrewMember;
            if(crewMember.m_recipeId == CraftingCrewMember.INVALID_RECIPE_ID)
            {
               crewCount++;
            }
         }
         var crewLeftCount:Number = crewCount - MAX_SLOTS;
         if(crewLeftCount < 0)
         {
            crewLeftCount = 0;
         }
         this.m_crewCountText.text = ZLocUtils.t("Dialogs","CraftshopFriendFrame_crew_amount_left",{"quantity":crewLeftCount});
      }
      
      override protected function getSlotPrefix() : String
      {
         return "slot_";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "_mc";
      }
   }
}

