package Classes.feed
{
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import ZLocalization.LocalizationToken;
   import flash.geom.Point;
   
   public class CraftingCottageFeed extends FarmFeed
   {
      
      private var m_callback:Function = null;
      
      private var m_localizationObj:Object = null;
      
      public function CraftingCottageFeed(bundleId:String, rewardUrl:String, localizationObj:Object, callback:Function = null)
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
         var prompt:GenericPopup = null;
         var locObj:Object = null;
         var locToken:LocalizationToken = null;
         var tokenName:String = null;
         if(targetIds != null)
         {
            m_targetUids = targetIds;
         }
         if(CraftingUI.getCraftingMainWindow())
         {
            CraftingUI.getCraftingMainWindow().tintWindow();
            CraftingUI.getCraftingMainWindow().enableInput = false;
         }
         if(m_bundleId != "" && m_params.reward_link != "")
         {
            message = "Dialogs:" + m_bundleId + "_prompt";
            if(ZLocUtils.hasString("Dialogs",m_bundleId + "_prompt"))
            {
               locObj = new Object();
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
            prompt = new GenericPopup(message,GenericPopup.TYPE_SHARECANCEL,this.onPromptClose);
            prompt.setTrackerKey("feed_" + m_bundleId);
            UI.displayPopupWithOffset(prompt,new Point(CraftingManager.CRAFTING_COTTAGE_POPUP_OFFSET_X,CraftingManager.CRAFTING_COTTAGE_POPUP_OFFSET_Y),addToQueue,"craftingFeedPrompt");
            FarmStatsManager.count("Crafting","Feed",m_bundleId,"impressions");
         }
      }
      
      public function onPromptClose(evt:GenericPopupEvent) : void
      {
         if(CraftingUI.getCraftingMainWindow())
         {
            CraftingUI.getCraftingMainWindow().untintWindow();
            CraftingUI.getCraftingMainWindow().enableInput = true;
         }
         if(evt.button == GenericPopup.ACCEPT)
         {
            m_publishCallback = this.m_callback;
            this.publish();
            FarmStatsManager.count("Crafting","Feed",m_bundleId,"share");
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
         m_publishCallback = this.m_callback;
         this.publish();
         FarmStatsManager.count("Crafting","Feed",m_bundleId,"share");
      }
   }
}

