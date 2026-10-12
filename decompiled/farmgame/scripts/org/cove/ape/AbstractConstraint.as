package org.cove.ape
{
   import flash.utils.getQualifiedClassName;
   
   public class AbstractConstraint extends AbstractItem
   {
      
      private var _stiffness:Number;
      
      public function AbstractConstraint(stiffness:Number)
      {
         super();
         if(getQualifiedClassName(this) == "org.cove.ape::AbstractConstraint")
         {
            throw new ArgumentError("AbstractConstraint can\'t be instantiated directly");
         }
         this.stiffness = stiffness;
         setStyle();
      }
      
      public function get stiffness() : Number
      {
         return this._stiffness;
      }
      
      public function set stiffness(s:Number) : void
      {
         this._stiffness = s;
      }
      
      public function resolve() : void
      {
      }
   }
}

