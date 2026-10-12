package Display
{
   import Classes.util.ZLocUtils;
   import flash.display.MovieClip;
   
   public class GenericFarmCashButton extends GenericButton
   {
      
      protected var m_cost:String = "";
      
      public function GenericFarmCashButton(target_mc:MovieClip, clickCallback:Function = null, val:String = "", overlayName:String = "")
      {
         super(target_mc,clickCallback,val,overlayName);
      }
      
      public function set cost(aCost:String) : void
      {
         this.m_cost = aCost;
         if(m_target.farmCash_tf)
         {
            this.m_target.farmCash_tf.text = this.m_cost;
            ZLocUtils.autoFormatSize(m_target.farmCash_tf,2237183);
         }
      }
   }
}

