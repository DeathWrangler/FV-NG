package Classes.feed
{
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingConstants;
   import Managers.FarmStatsManager;
   import Widgets.Windows.Crafting.CraftingStartOrFinishRecipeWindow;
   import ZLocalization.LocalizationToken;
   
   public class CraftshopFeed extends FarmFeed
   {
      
      private var m_callback:Function = null;
      
      private var m_crewUsed:Boolean = false;
      
      private var m_recipeCrew:Array = null;
      
      private var m_dialogIcon:String = "assets/buildings/bldg_craftingworkshop_icon.png";
      
      private var m_localizationObj:Object = null;
      
      public function CraftshopFeed(bundleId:String, rewardUrl:String, localizationObj:Object, callback:Function = null, crewRecipeId:String = "", dialogIcon:String = null)
      {
         var index:String = null;
         super();
         this.m_localizationObj = localizationObj;
         if(null == this.m_localizationObj)
         {
            this.m_localizationObj = new Object();
         }
         this.m_localizationObj.actor = Global.player.firstName + ":" + Global.player.snUser.gender;
         m_bundleId = bundleId;
         m_params.rewardLink = rewardUrl;
         m_params.first_name = Global.player.firstName;
         m_params.modifierLevel = Global.craftConfigSettings.getFinishRewardLevel().toString();
         this.m_callback = callback;
         for(index in this.m_localizationObj)
         {
            m_params[index] = this.m_localizationObj[index];
         }
         if(null != crewRecipeId && "" != crewRecipeId)
         {
            this.setCrewNames(crewRecipeId);
         }
         if(null != dialogIcon)
         {
            this.m_dialogIcon = dialogIcon;
         }
         this.m_dialogIcon = Global.getAssetURL(this.m_dialogIcon);
      }
      
      private function setCrewNames(crewRecipeId:String) : void
      {
         var iCrew:int = 0;
         var friendObj:Friend = null;
         this.m_recipeCrew = Global.player.craftingState.getCrewOnRecipe(crewRecipeId);
         if(this.m_recipeCrew.length >= CraftingConstants.CRAFTSHOP_NUM_HELPERS)
         {
            m_bundleId += "Helpers";
            this.m_crewUsed = true;
            for(iCrew = 0; iCrew < this.m_recipeCrew.length; iCrew++)
            {
               friendObj = Global.friendManager.getAppFriendData(this.m_recipeCrew[iCrew].m_uid);
               m_params["crewName" + iCrew.toString()] = Boolean(friendObj) && Boolean(friendObj.firstName) ? friendObj.firstName : ZLocUtils.t("Dialogs","CraftingNamelessFriend");
            }
         }
      }
      
      public function setImage(imageUrl:String, isAssetURL:Boolean = false) : void
      {
         var image:String = imageUrl;
         if(!isAssetURL)
         {
            image = Global.getAssetURL(imageUrl);
         }
         m_params.images = [{
            "href":"{SN_APP_URL}" + m_params.rewardLink,
            "src":image
         }];
      }
      
      public function startFeedFlow(addToQueue:Boolean = false, targetIds:Array = null) : void
      {
         var message:String = null;
         var locObj:Object = null;
         var acceptText:String = null;
         var crewIndex:int = 0;
         var locToken:LocalizationToken = null;
         var tokenName:String = null;
         var prompt:GenericIconPopup = null;
         if(targetIds != null)
         {
            m_targetUids = targetIds;
         }
         if(m_bundleId != "" && m_params.reward_link != "")
         {
            if(this.m_crewUsed)
            {
               for(crewIndex = 0; crewIndex < CraftingConstants.CRAFTSHOP_NUM_HELPERS; crewIndex++)
               {
                  this.m_localizationObj["crewName" + crewIndex.toString()] = m_params["crewName" + crewIndex.toString()];
               }
            }
            message = "Dialogs:" + m_bundleId + "_prompt";
            locObj = new Object();
            if(ZLocUtils.hasString("Dialogs",m_bundleId + "_prompt"))
            {
               for(tokenName in this.m_localizationObj)
               {
                  if(this.m_localizationObj[tokenName] != null)
                  {
                     locToken = ZLocUtils.makeToken("Dialogs",m_bundleId + "_prompt",tokenName,this.m_localizationObj[tokenName]);
                     locObj[tokenName] = null != locToken ? locToken : this.m_localizationObj[tokenName];
                  }
               }
               message = ZLocUtils.t("Dialogs",m_bundleId + "_prompt",locObj);
            }
            acceptText = m_bundleId + "_AcceptButton";
            if(m_bundleId == "CraftingRecipeLevelUp" || m_bundleId == "CraftingRecipeMastered")
            {
               prompt = new GenericIconPopup(message,GenericPopup.TYPE_OK,this.onPromptClose,this.m_dialogIcon);
               prompt.setAcceptTextName(acceptText);
               prompt.setTrackerKey("feed_" + m_bundleId);
               UI.displayPopup(prompt,addToQueue,"craftingFeedPrompt");
            }
            else
            {
               UI.displayPopup(new CraftingStartOrFinishRecipeWindow(m_bundleId,this.m_dialogIcon,this.m_recipeCrew,acceptText,locObj,this.setCallbackAndPublishFeed,this.m_callback),addToQueue);
            }
            FarmStatsManager.count("Crafting","Feed",m_bundleId,"impressions");
         }
      }
      
      public function onPromptClose(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT)
         {
            this.setCallbackAndPublishFeed();
         }
         else if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
      
      public function publishFeedWithoutPrompt(targetIds:Array = null) : void
      {
         if(targetIds != null)
         {
            m_targetUids = targetIds;
         }
         this.setCallbackAndPublishFeed();
      }
      
      public function setCallbackAndPublishFeed() : void
      {
         m_publishCallback = this.m_callback;
         this.publish();
         FarmStatsManager.count("Crafting","Feed",m_bundleId,"share");
      }
   }
}

