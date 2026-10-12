package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.OlyInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class OlyInnovationProgresswindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const ICON_MC:String = "icon_mc";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const ACCEPT_BT:String = "accept_bt";
      
      private const TEXT_TITLE:String = "_progresswindowtitle";
      
      private const TEXT_DESC:String = "_progresswindowdescription";
      
      private const TEXT_AOE_DESC:String = "_aoewindowdescription";
      
      private const TEXT_ACCEPT_BT:String = "_progresswindowbutton";
      
      protected var m_featureName:String;
      
      private var m_tileHoverWidgets:Vector.<ZwWidget> = new Vector.<ZwWidget>();
      
      private var m_buildingHoverWidgets:Vector.<ZwWidget> = new Vector.<ZwWidget>();
      
      private var m_taskName:String;
      
      private var m_taskSlot:MovieClip;
      
      private var m_isTotem:Boolean;
      
      public function OlyInnovationProgresswindow(assetUrl:String, featureName:String, taskName:String, isTotem:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_taskName = taskName;
         this.m_isTotem = isTotem;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var allRegions:Array = null;
         var currentRegion:String = null;
         var slotIndex:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)));
         }
         if(m_window.hasOwnProperty(this.DESCRIPTION_TF))
         {
            if(this.m_isTotem)
            {
               allRegions = OlyInnovationManager.getInstance().getAllRegionNames();
               currentRegion = OlyInnovationManager.getInstance().getRegionNameForTotem(this.m_taskName);
               allRegions = this.removeCurrentRegionFromRegionArray(currentRegion,allRegions);
               addWidget(new ZwTextField(m_window[this.DESCRIPTION_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_AOE_DESC,{
                  "region1":allRegions[0],
                  "region2":allRegions[1]
               })));
            }
            else
            {
               addWidget(new ZwTextField(m_window[this.DESCRIPTION_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_DESC))) as ZwTextField;
            }
         }
         if(m_window.hasOwnProperty(this.ACCEPT_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.ACCEPT_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_ACCEPT_BT),this.onAccept));
         }
         if(m_window.hasOwnProperty(this.ICON_MC))
         {
            this.m_taskSlot = m_window[this.ICON_MC] as MovieClip;
            this.m_taskSlot.visible = true;
            slotIndex = OlyInnovationManager.getInstance().mapTaskNameToSlotIndex(this.m_taskName);
            this.m_taskSlot.gotoAndStop(slotIndex);
         }
         this.loadFire();
         FarmStatsManager.count(this.m_featureName,"feature_ui","reward_window","open");
      }
      
      private function removeCurrentRegionFromRegionArray(currentRegion:String, regionArray:Array) : Array
      {
         var resultArray:Array = new Array();
         for(var i:int = 0; i < regionArray.length; i++)
         {
            if(currentRegion != regionArray[i])
            {
               resultArray.push(regionArray[i]);
            }
         }
         return resultArray;
      }
      
      private function loadFire() : void
      {
         var fireIndex:int = 0;
         while(m_window.hasOwnProperty("fire_" + fireIndex))
         {
            (m_window["fire_" + fireIndex] as MovieClip).visible = true;
            fireIndex++;
         }
      }
      
      private function onAccept(event:Event) : void
      {
         this.close();
         if(this.m_isTotem)
         {
            OlyInnovationManager.getInstance().panToTotem(this.m_taskName);
         }
         else
         {
            OlyInnovationManager.getInstance().showFeatureUI();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         this.onAccept(event);
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
      }
   }
}

