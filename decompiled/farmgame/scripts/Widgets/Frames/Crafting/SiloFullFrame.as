package Widgets.Frames.Crafting
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class SiloFullFrame extends ZwFrame
   {
      
      public function SiloFullFrame(element:MovieClip, renderMode:String)
      {
         super(element);
         addWidget(new ZwTextField(m_element.siloFull_tf,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_SiloFull")));
         if(renderMode == "bushels")
         {
            addWidget(new ZwTextField(m_element.makeSpace_tf,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_SiloFullCTA")));
         }
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

