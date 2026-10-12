package Widgets.Slots.CaptureFeatureBuilding
{
   import Classes.ZItem.GopherItem;
   import Classes.util.ZLocUtils;
   import Managers.CaptureFeatureManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CaptureFeatureBuilding.CaptureFeatureObjectPreviewFrame;
   import Widgets.Frames.CaptureFeatureBuilding.CaptureFeatureRewardFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Tooltips.MovieClipTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class FeatureItemSlot extends ZwSlotFrame
   {
      
      private const PREVIEW_SCALE:int = 4;
      
      private var m_gopherName_tf:ZwTextField;
      
      private var m_gopherImage_mc:ObjectPreviewFrame;
      
      private var m_capture_tf:ZwTextField;
      
      private var m_buildingLevel:int;
      
      private var m_featureName:String;
      
      public function FeatureItemSlot(featureName:String, element:DisplayObject, buildingLevel:int)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_buildingLevel = buildingLevel;
         this.m_gopherName_tf = addWidget(new ZwTextField(m_element.tooltip_mc.gopherName_tf)) as ZwTextField;
         addWidget(new ZwTextField(m_element.tooltip_mc.wanted_tf,ZLocUtils.t("Dialogs",CaptureFeatureManager.instance.getStringsPrefix(this.m_featureName) + "_GopherWanted")));
         addWidget(new ZwTextField(m_element.tooltip_mc.body_tf));
         this.m_capture_tf = addWidget(new ZwTextField(m_element.capture_mc.amount_tf)) as ZwTextField;
      }
      
      override public function populate(data:Object) : void
      {
         var prefix:String = null;
         var captureCount:int = 0;
         var rewards:Array = null;
         super.populate(data);
         m_element.tooltip_mc.wanted_tf.visible = true;
         m_element.tooltip_mc.body_tf.visible = true;
         var gopher:GopherItem = data as GopherItem;
         if(gopher)
         {
            this.m_gopherName_tf.text = gopher.friendlyTitle;
            this.m_gopherName_tf.visible = true;
            if(this.m_gopherImage_mc)
            {
               removeWidget(this.m_gopherImage_mc);
            }
            this.m_gopherImage_mc = addWidget(new CaptureFeatureObjectPreviewFrame(m_element.gopherImage_mc,gopher,null,[this.PREVIEW_SCALE])) as ObjectPreviewFrame;
            prefix = CaptureFeatureManager.instance.getStringsPrefix(this.m_featureName);
            if(gopher.requiredBuildingLevel > this.m_buildingLevel)
            {
               m_element.tooltip_mc.body_tf.text = ZLocUtils.t("Dialogs",prefix + "_GopherRequiresLevel",{"level":gopher.requiredBuildingLevel + 1});
               m_element.lockIcon_mc.visible = true;
            }
            else if(gopher.requiredTreats > 1)
            {
               m_element.tooltip_mc.body_tf.text = ZLocUtils.t("Dialogs",prefix + "_GopherRequiresTreats",{"treatCount":gopher.requiredTreats});
               m_element.lockIcon_mc.visible = false;
            }
            else
            {
               m_element.tooltip_mc.body_tf.text = ZLocUtils.t("Dialogs",prefix + "_GopherRequiresTreat");
               m_element.lockIcon_mc.visible = false;
            }
            captureCount = gopher.getCaptureCount();
            if(captureCount > 0)
            {
               this.m_capture_tf.text = ZLocUtils.t("Dialogs",prefix + "_GopherCaptureCount",{"count":captureCount});
               this.m_capture_tf.visible = true;
               m_element.capture_mc.visible = true;
            }
            else
            {
               m_element.capture_mc.visible = false;
            }
            rewards = CaptureFeatureManager.instance.getCaptureItemRewardData(this.m_featureName,gopher.name);
            removeWidget(m_element.reward_mc);
            addWidget(new CaptureFeatureRewardFrame(m_element.reward_mc,rewards,30,30,false));
            this.attachTooltip(new MovieClipTooltip(m_element as MovieClip,8,1));
         }
      }
   }
}

