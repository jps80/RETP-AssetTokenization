import { IsDateString, IsIn, IsNotEmpty, IsNumberString, IsOptional, IsString, Length, Matches, MaxLength, MinLength } from 'class-validator';

export class CreateSpvDto {
  @IsString()
  @Matches(/^[A-Z0-9][A-Z0-9_-]{2,31}$/)
  code!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(160)
  name!: string;

  @IsString()
  @Length(2, 2)
  @IsIn(['ES'])
  jurisdiction!: string;

  @IsString()
  @IsIn(['SL'])
  legalForm!: string;

  @IsString()
  @Matches(/^[A-Z0-9_-]{2,24}$/)
  capitalClassCode!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  capitalClassName!: string;

  @IsNumberString()
  @Matches(/^(?:0|[1-9]\\d{0,17})(?:\\.\\d{1,2})?$/)
  nominalValue!: string;

  @IsString()
  @Matches(/^[1-9]\\d{0,18}$/)
  legallyCreatedUnits!: string;

  @IsOptional()
  @IsDateString()
  effectiveDate?: string;
}