package Widgets.Windows.Crafting
{
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class CraftingStartOrFinishRecipeWindow extends FarmWindow
   {
      
      private static const ASSET:String = "assets/dialogs/FV_Craftshop_start_v2.swf";
      
      protected var m_bundleId:String = "";
      
      protected var m_recipeIcon:String = "";
      
      protected var m_recipeCrew:Array = null;
      
      protected var m_shareText:String = "";
      
      protected var m_localizationObj:Object = null;
      
      protected var m_onShareCallback:Function = null;
      
      protected var m_onOkayCallback:Function = null;
      
      public function CraftingStartOrFinishRecipeWindow(bundleId:String, recipeIcon:String, recipeCrew:Array, shareText:String, localizationObj:Object, onShareCallback:Function, onOkayCallback:Function)
      {
         this.m_bundleId = bundleId;
         this.m_recipeIcon = recipeIcon;
         this.m_recipeCrew = recipeCrew;
         this.m_shareText = shareText;
         this.m_localizationObj = localizationObj;
         this.m_onShareCallback = onShareCallback;
         this.m_onOkayCallback = onOkayCallback;
         super(ASSET);
      }
      
      override protected function postLoadComplete() : void
      {
         var recipeIcon:FarmIcon = null;
         var recipeCount:ZwTextField = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_bundleId + "_title",this.m_localizationObj)));
         }
         if(m_window.hasOwnProperty("desc_tf"))
         {
            addWidget(new ZwTextField(m_window.desc_tf,ZLocUtils.t("Dialogs",this.m_bundleId + "_desc",this.m_localizationObj)));
         }
         if(m_window.hasOwnProperty("icon_mc"))
         {
            recipeIcon = new FarmIcon(m_window.icon_mc,this.m_recipeIcon);
            recipeIcon.setSmoothing(true);
            addWidget(recipeIcon);
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.share_bt,this.m_shareText,this.onShareClick));
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("Crafting","General_Okay"),this.onOkayClick));
         }
         var nReward:int = 1;
         if(this.m_recipeCrew != null && this.m_recipeCrew.length >= CraftingConstants.CREW_NEEDED_FOR_BONUS_ITEM)
         {
            nReward++;
         }
         if(m_window.hasOwnProperty("counter_tf"))
         {
            recipeCount = addWidget(new ZwTextField(m_window.counter_tf,"counter_tf")) as ZwTextField;
            recipeCount.text = ZLocUtils.t("Dialogs","CraftshopRecipeSlot_RewardCount",{"quantity":nReward.toString()});
            recipeCount.visible = true;
         }
      }
      
      private function onShareClick(event:MouseEvent) : void
      {
         this.close();
         this.m_onShareCallback();
      }
      
      private function onOkayClick(event:MouseEvent) : void
      {
         this.close();
         this.m_onOkayCallback();
      }
   }
}

