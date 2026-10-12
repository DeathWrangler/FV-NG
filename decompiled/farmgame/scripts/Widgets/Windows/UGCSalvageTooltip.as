package Widgets.Windows
{
   import Classes.EmbeddedArt;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import flash.display.DisplayObject;
   import flash.text.TextField;
   
   public class UGCSalvageTooltip extends ZwAbstractWindow
   {
      
      private var m_tooltipDisplayObject:DisplayObject;
      
      private var m_materialsFrame:ZwFrame;
      
      private var m_materials:Array;
      
      public function UGCSalvageTooltip()
      {
         super(null);
         this.m_tooltipDisplayObject = new EmbeddedArt.aoeTooltipMC() as DisplayObject;
         this.hideElements();
         if(this.m_tooltipDisplayObject["title_tf"])
         {
            addWidget(new ZwTextField(this.m_tooltipDisplayObject["title_tf"],ZLocUtils.t("Dialogs","UGCDecoWindow_recycle_tooltip_title")));
         }
         visible = true;
         addChild(this.m_tooltipDisplayObject);
      }
      
      public function setMaterials(materials:Array) : void
      {
         this.m_materials = materials;
         if(this.m_materialsFrame)
         {
            removeWidget(this.m_materialsFrame);
         }
         this.resetMaterials();
      }
      
      private function resetMaterials() : void
      {
         var clipname:String = null;
         var statusString:String = null;
         var keyCount:int = 0;
         var textClipname:String = null;
         var material:Object = null;
         var materialItem:FarmItem = null;
         if(this.m_materials)
         {
            clipname = this.getClipname(this.m_materials.length);
            if(this.m_tooltipDisplayObject.hasOwnProperty(clipname) && this.m_tooltipDisplayObject[clipname] != null)
            {
               this.m_materialsFrame = new ZwFrame(this.m_tooltipDisplayObject[clipname]);
               this.addWidget(this.m_materialsFrame);
               keyCount = 0;
               for each(material in this.m_materials)
               {
                  materialItem = Global.farmGameSettingsManager.getFarmItemByName(material["name"]);
                  if(materialItem)
                  {
                     statusString = materialItem.friendlyTitle;
                     textClipname = "body" + keyCount + "_tf";
                     if(this.m_materialsFrame.element.hasOwnProperty(textClipname) && this.m_materialsFrame.element[textClipname] != null)
                     {
                        this.m_materialsFrame.addWidget(new ZwTextField(this.m_materialsFrame.element[textClipname],statusString));
                        (this.m_materialsFrame.element[textClipname] as TextField).selectable = false;
                     }
                     keyCount++;
                  }
               }
            }
         }
      }
      
      private function hideElements() : void
      {
         if(this.m_tooltipDisplayObject["title_0_tf"])
         {
            this.m_tooltipDisplayObject["title_0_tf"].visible = false;
         }
         if(this.m_tooltipDisplayObject["title_1_tf"])
         {
            this.m_tooltipDisplayObject["title_1_tf"].visible = false;
         }
         if(this.m_tooltipDisplayObject["title_tf"])
         {
            this.m_tooltipDisplayObject["title_tf"].visible = false;
         }
         if(this.m_tooltipDisplayObject["oneLine_mc"])
         {
            this.m_tooltipDisplayObject["oneLine_mc"].visible = false;
         }
         if(this.m_tooltipDisplayObject["twoLines_mc"])
         {
            this.m_tooltipDisplayObject["twoLines_mc"].visible = false;
         }
         if(this.m_tooltipDisplayObject["threeLines_mc"])
         {
            this.m_tooltipDisplayObject["threeLines_mc"].visible = false;
         }
      }
      
      private function getClipname(count:int) : String
      {
         var clipname:String = null;
         switch(count)
         {
            case 1:
               clipname = "oneLine_mc";
               break;
            case 2:
               clipname = "twoLines_mc";
               break;
            case 3:
               clipname = "threeLines_mc";
               break;
            default:
               clipname = "threeLines_mc";
         }
         return clipname;
      }
   }
}

